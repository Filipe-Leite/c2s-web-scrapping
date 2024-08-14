class ProductsController < ApplicationController
  def create
    begin
      token = request.headers['Authorization']&.split(' ')&.last

      TaskMicroservice.update(params[:task_id], 2, token)

      scraper = ProductScraper.new(params[:url])
      scraping_result = scraper.scrape

      if scraping_result
        @product = Product.new(scraping_result)

        if @product.save
          TaskMicroservice.update(params[:task_id], 3, token)
          render json: @product, status: :ok
        else
          TaskMicroservice.update(params[:task_id], 4, token)
          render json: @product.errors, status: :unprocessable_entity
        end
      else
        TaskMicroservice.update(params[:task_id], 4, token)
        render json: { error: 'Web scraping failed' }, status: :unprocessable_entity
      end
    rescue => e
      TaskMicroservice.update(params[:task_id], 4, token)
      Rails.logger.error "Internal server error: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def product_params
    params.permit(:task_id, :url)
  end
end
