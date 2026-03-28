module Manage
  class ConfigsController < BaseController
    def index
      @configs = AppConfig.order(:key)
    end

    def update
      @config = AppConfig.find(params[:id])
      if @config.update(config_params)
        redirect_to manage_configs_path, notice: "#{@config.key} updated."
      else
        @configs = AppConfig.order(:key)
        render :index, status: :unprocessable_entity
      end
    end

    private

    def config_params
      params.require(:app_config).permit(:value)
    end
  end
end
