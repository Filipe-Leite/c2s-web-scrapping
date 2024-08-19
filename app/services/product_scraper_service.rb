class ProductScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    scraper = case
                when @url.include?('havan.com')
                  Havan::HavanProductScraper.new(@url)
                when @url.include?('webmotors.com')
                  WebMotors::WebMotorsProductScraper.new(@url)
                else
                  {
                    brand: nil,
                    model: nil,
                    price: nil
                  }
              end

    scraper.scrape
  end
end
