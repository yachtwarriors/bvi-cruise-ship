module Manage
  class ThresholdsController < BaseController
    def index
      @thresholds = CrowdThreshold.includes(:location).all
    end

    def update
      @threshold = CrowdThreshold.find(params[:id])
      if @threshold.update(threshold_params)
        redirect_to admin_thresholds_path, notice: "Threshold for #{@threshold.location.name} updated."
      else
        @thresholds = CrowdThreshold.includes(:location).all
        render :index, status: :unprocessable_entity
      end
    end

    private

    def threshold_params
      params.require(:crowd_threshold).permit(:green_max, :yellow_max)
    end
  end
end
