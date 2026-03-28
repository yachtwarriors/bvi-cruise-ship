# User Accounts & Daily Email Alerts Plan

**Date:** 2026-03-28
**Scope:** Devise User model, account page with alert date range, daily Postmark email

## Architecture Decisions

- **Devise for User model** (separate from Admin) — Admin stays minimal, User gets registration + password recovery + alert dates
- **postmark-rails** for email delivery — same as Yacht Warriors
- **Date range (start/end)** — not individual dates. Users pick their charter week
- **deliver_now** in rake task — Heroku Scheduler runs one-off dynos that shut down after task completes; async jobs might not finish
- **Native HTML date inputs** — works great on mobile, no JS dependency needed
- **Env vars for feature flags** — simpler than AppConfig for Heroku one-off dynos

## Phase 1: Gem + User Model

### 1. Add gem to Gemfile
```ruby
gem 'postmark-rails'
```

### 2. Generate Devise User model
```
rails generate devise User
```

### 3. Modify migration
Add to the generated migration:
```ruby
# Alert date range
t.date :alert_start_date
t.date :alert_end_date
t.boolean :email_enabled, default: false, null: false

# Index for daily email query
add_index :users, [:alert_start_date, :alert_end_date]
```

### 4. User model (`app/models/user.rb`)
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :alert_end_date, comparison: { greater_than_or_equal_to: :alert_start_date },
            if: -> { alert_start_date.present? && alert_end_date.present? }

  scope :with_active_alerts_for, ->(date) {
    where("alert_start_date <= ? AND alert_end_date >= ?", date, date)
  }
  scope :email_enabled, -> { where(email_enabled: true) }
end
```

### 5. Devise config (`config/initializers/devise.rb`)
```ruby
config.mailer_sender = 'alerts@bvicruiseshipschedule.com'
config.scoped_views = true
```

## Phase 2: Routes + Auth Views

### 6. Routes (`config/routes.rb`)
```ruby
devise_for :users, path: "users", path_names: { sign_in: "login", sign_up: "signup" }
resource :account, only: [:show, :update], controller: "accounts"
```

Produces: `/users/signup`, `/users/login`, `/users/password/new`, `/account`

### 7. Views to create
- `app/views/users/registrations/new.html.erb` — sign up (email + password)
- `app/views/users/sessions/new.html.erb` — login
- `app/views/users/passwords/new.html.erb` — forgot password
- `app/views/users/passwords/edit.html.erb` — reset password

All styled with Tailwind: white card, max-w-md, centered. Match existing site aesthetic.

### 8. Layout header update (`app/views/layouts/application.html.erb`)
- Signed in: "My Account" + "Log Out"
- Signed out: "Sign Up" / "Log In"
- Use `user_signed_in?` / `current_user` helpers

## Phase 3: Account Page

### 9. AccountsController (`app/controllers/accounts_controller.rb`)
```ruby
class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(account_params)
      redirect_to account_path, notice: "Alert dates updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:alert_start_date, :alert_end_date)
  end
end
```

### 10. Account view (`app/views/accounts/show.html.erb`)
- Current email display
- Two native `<input type="date">` fields: start_date and end_date
- "Save Dates" button
- "Remove Alerts" link (clears both dates)
- "Change Password" link

## Phase 4: Mailer + Rake Task

### 11. Postmark config (`config/application.rb`)
```ruby
config.action_mailer.delivery_method = :postmark
config.action_mailer.postmark_settings = { api_token: ENV['POSTMARK_API_TOKEN'] }
```

### 12. ApplicationMailer update
```ruby
default from: '"BVI Cruise Ship Schedule" <alerts@bvicruiseshipschedule.com>'
```

### 13. DailyCrowdAlertMailer (`app/mailers/daily_crowd_alert_mailer.rb`)
```ruby
class DailyCrowdAlertMailer < ApplicationMailer
  def daily_alert(user, date)
    @user = user
    @date = date
    @visits = CruiseVisit.includes(:port).on_date(date)
    @locations = Location.includes(:crowd_threshold).all
    @snapshots = CrowdSnapshot.includes(:location)
                              .on_date(date).daytime.ordered
                              .group_by(&:location_id)
    mail(to: user.email, subject: "BVI Crowd Report — #{date.strftime('%A, %B %-d')}")
  end
end
```

### 14. Email template (`app/views/daily_crowd_alert_mailer/daily_alert.html.erb`)

Structure:
1. **Header:** "BVI Crowd Report" + date
2. **Ships summary:** Total guests (big number), ship count, list with names/ports/capacity
3. **Per-location:** Name + peak risk badge + "Best time: Before 9 AM" (find longest green window)
4. **Quick tip:** "Heavy cruise day — go early" or "Light day — great for The Baths"
5. **Cross-sell:** YW CTA (on yellow/red days only) + CharterProtect footer (always)
6. **Footer:** "Alerts set for [dates]. Manage: [/account link]"

Also create `daily_alert.text.erb` plain text version.

### 15. Rake task (`lib/tasks/email.rake`)
```ruby
namespace :email do
  task send_daily_alerts: :environment do
    date = Time.use_zone("America/Virgin") { Time.zone.today }
    next unless ENV['DAILY_EMAIL_ENABLED'] == 'true'

    users = User.with_active_alerts_for(date).email_enabled
    if ENV['MATT_ONLY_EMAILS'] == 'true'
      users = users.where(email: ENV.fetch('MATT_EMAIL', 'matt@yachtwarriors.com'))
    end

    users.find_each do |user|
      DailyCrowdAlertMailer.daily_alert(user, date).deliver_now
    rescue => e
      Rails.logger.error("Failed to send alert to #{user.email}: #{e.message}")
    end
  end
end
```

### 16. Heroku Scheduler job
- Command: `rake email:send_daily_alerts`
- Time: 10:30 UTC (6:30 AM AST)

## Phase 5: Launch Sequence

### Heroku env vars to set:
```
POSTMARK_API_TOKEN=<from Postmark>
DAILY_EMAIL_ENABLED=true
MATT_ONLY_EMAILS=true
MATT_EMAIL=matt@yachtwarriors.com
```

### Rollout:
1. Deploy code
2. Create Matt's user account via console, set alert dates, `email_enabled: true`
3. Wait for next morning send — verify email arrives via Postmark dashboard
4. Once confirmed, set `MATT_ONLY_EMAILS=false` to open to all users

## File Summary

| File | Action |
|------|--------|
| Gemfile | Add `postmark-rails` |
| db/migrate/XXX_devise_create_users.rb | New migration |
| app/models/user.rb | New model |
| config/initializers/devise.rb | Update mailer_sender, scoped_views |
| config/routes.rb | Add user devise + account route |
| config/application.rb | Add Postmark config |
| app/controllers/accounts_controller.rb | New controller |
| app/mailers/application_mailer.rb | Update from address |
| app/mailers/daily_crowd_alert_mailer.rb | New mailer |
| app/views/users/**/*.html.erb | 4 new auth views |
| app/views/accounts/show.html.erb | New account page |
| app/views/daily_crowd_alert_mailer/*.erb | 2 new email templates |
| app/views/layouts/application.html.erb | Add nav links |
| lib/tasks/email.rake | New rake task |
