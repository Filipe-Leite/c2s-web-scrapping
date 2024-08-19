require 'selenium-webdriver'
require 'nokogiri'
module Havan
    class HavanProductScraper
      def initialize(url)
        @url = url
        puts "URL inicializada: #{@url}"
      end
    
      def scrape
        puts "Iniciando scrape..."
    
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        driver = Selenium::WebDriver.for :chrome, options: options
    
        begin
          driver.get(@url)
          puts "Página carregada com sucesso"
    
          wait = Selenium::WebDriver::Wait.new(timeout: 15)
          begin
            wait.until { driver.find_element(css: '.page-title-wrapper') }
            puts "Elemento principal encontrado"
          rescue Selenium::WebDriver::Error::TimeoutError
            puts "Elemento principal não encontrado no tempo limite"
          end
    
          html_content = driver.page_source
          puts "Conteúdo HTML obtido com sucesso"
    
          doc = Nokogiri::HTML(html_content)
          puts "Documento Nokogiri criado com sucesso"
    
          {
            brand: extract_brand(doc),
            model: extract_model(doc),
            price: extract_price(doc)
          }
        rescue StandardError => e
          puts "Erro durante o scrape: #{e.message}"
          {
            brand: nil,
            model: nil,
            price: nil
          }
        ensure
          driver.quit
        end
      end
    
      private
    
      def extract_brand(doc)
        brand_element = doc.css('#ficha-tecnica > div > table > tbody > tr:nth-child(4) > td:nth-child(2)')
        brand = brand_element ? brand_element.text.strip : 'Brand not found'
        brand
      end
    
      def extract_model(doc)
        model_element = doc.css('#maincontent > div.columns > div > div.product.media > div.page-title-wrapper.product > h1 > span')
        model = model_element ? model_element.text.strip : 'Model not found'
        model
      end
    
      def extract_price(doc)
    
        puts "Extraindo preço..."
    
        selectors = [
          '#maincontent > div.columns > div.column.main > div:first-child > div:nth-child(2) > 
          div:first-child > span > span > span']
        
        price = nil
      
        selectors.each do |selector|
          element = doc.css(selector)
          if element
            price_text = element.text.gsub('R$', '').gsub('.', '').gsub(',', '.').strip
    
            price_text_clean = price_text.gsub(/[^\d.]/, '')
    
            if price_text_clean == ''
              price = nil
            else
              price = price_text_clean.to_f
            end
            
            break
          end
        end
      
        price
      end
      
    end
end

