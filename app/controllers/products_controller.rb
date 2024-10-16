require 'open3'
require 'json'

class ProductsController < ApplicationController

  def index
    @products = Product.all

    render json: @products, status: :ok
  end  


  def create
    begin
      token = request.headers['Authorization']&.split(' ')&.last
  
      TaskMicroservice.update(params[:task_id], 2, token)
  
      script_path = Rails.root.join('app', 'services', 'scraper.py').to_s
      url = params[:url]

      # result = `python3 #{script_path} #{url}`

      # scraper = HavanProductScraper.new(url)
      # scraping_result = scraper.scrape
      
      scraper_service = ProductScraperService.new(url)

      scraping_result = scraper_service.scrape
  
      scraping_result = scraping_result.merge(task_id: params[:task_id])
      
      if scraping_result && scraping_result[:error].nil?
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
