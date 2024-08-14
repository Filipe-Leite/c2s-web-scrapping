require 'nokogiri'
require 'open-uri'

class ProductScraper
  def initialize(url)
    @url = url

    # @url = 'https://www.havan.com.br/caixa-de-som-bluetooth-jbl-partybox-encore-preto-2micbr/p'
  end

  def scrape
    html_content = URI.open(@url)
    doc = Nokogiri::HTML(html_content)

    {
      brand: extract_brand(doc),
      model: extract_model(doc),
      price: extract_price(doc)
    }
  rescue StandardError => e
    Rails.logger.error "Ocorreu um erro: #{e.message}"
    {
      brand: 'Brand not found',
      model: 'Model not found',
      price: 'Price not found'
    }
  end

  private

  def extract_brand(doc)
    brand_element = doc.at_xpath('//*[@id="maincontent"]/div[2]/div/div[2]/div[1]/h1/span')
    brand_element ? brand_element.text.strip : 'Brand not found'
  end

  def extract_model(doc)
    model_element = doc.at_xpath('//*[@id="maincontent"]/div[2]/div/div[2]/div[1]/h1/span')
    model_element ? model_element.text.strip : 'Model not found'
  end

  def extract_price(doc)
    price_element = doc.at_xpath('//*[@id="maincontent"]/div[2]/div/div[2]/div[1]/h1/span')
    price_element ? price_element.text.strip : 'Price not found'
  end
end