require 'selenium-webdriver'
require 'nokogiri'

module WebMotors
  class WebMotorsProductScraper
    def initialize(url)
      @url = url
      puts "URL inicializada: #{@url}"
    end

    def scrape
      
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
    
      proxys_list = get_proxys_list

      get_proxys_list.each do |proxy|

        options.add_argument("--proxy-server=#{proxy}")
      
        driver = Selenium::WebDriver.for :chrome, options: options
      
        begin
          driver.navigate.to @url
          puts "Página carregada com sucesso"
      
          wait = Selenium::WebDriver::Wait.new(timeout: 10)
      
          begin
            wait.until { driver.find_element(css: '.VehicleDetails__header') }
            puts "Elemento principal encontrado"
          rescue Selenium::WebDriver::Error::TimeoutError
            puts "Elemento principal não encontrado no tempo limite"
            next
          end
      
          html_content = driver.page_source
          puts "Conteúdo HTML obtido com sucesso"
      
          doc = Nokogiri::HTML(driver.page_source)
          
          result = {
            brand: extract_brand(doc),
            model: extract_model(doc),
            price: extract_price(doc)
          }
          
          puts "Resultado do scrape: #{result}"
          break if result[:brand] != 'Brand not found' && result[:model] != 'Model not found' && result[:price] != 'Price not found'
      
        rescue StandardError => e
          puts "Erro durante o scrape: #{e.message}"
          next
        ensure
          driver.quit
        end
      end
    end

    private

    def extract_brand(doc)
      brand_element = doc.css('#VehiclePrincipalInformationLocation')
      brand = brand_element ? brand_element.text.strip : 'Brand not found'
      brand
    end

    def extract_model(doc)
      model_element = doc.css('#VehiclePrincipalInformationLocation')
      model = model_element ? model_element.text.strip : 'Model not found'

      p "model_element >> #{model_element}"
      p "model >> #{model}"
      model
    end

    def extract_price(doc)
      puts "Extraindo preço..."

      selectors = [
        'div.VehicleDetailsFipe__price:nth-child(1) > strong:nth-child(2)',
        'div.VehicleDetailsFipe__price:nth-child(1) > strong:nth-child(2)',
        'div.VehicleDetailsFipe__price:nth-child(1) > strong:nth-child(2)'
      ]
    
      price = nil
    
      selectors.each do |selector|
        element = doc.css(selector) || doc.xpath(selector)
    
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

    def get_proxys_list
      
      proxys_list = []

      proxy_provider_site_url = 'https://www.freeproxy.world/?type=&anonymity=&country=&speed=&port=&page=1#google_vignette'

      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')

      driver = Selenium::WebDriver.for :chrome, options: options
      driver.get(proxy_provider_site_url)

      # wait = Selenium::WebDriver::Wait.new(timeout: 5)
      html_content = driver.page_source

      doc = Nokogiri::HTML(html_content)

      # best_proxy = nil
      # selected_row = nil

      row = 2
      page = 1
      while proxys_list.length < 10

        if row == 100
        
          page += 1

          proxy_provider_site_url = "https://www.freeproxy.world/?type=&anonymity=&country=&speed=&port=&page=#{row}#google_vignette"
          options = Selenium::WebDriver::Chrome::Options.new
          options.add_argument('--headless')
          driver = Selenium::WebDriver.for :chrome, options: options
          driver.get(proxy_provider_site_url)
          html_content = driver.page_source
    
          doc = Nokogiri::HTML(html_content)
        end

        speed = doc.css(".layui-table > tbody:nth-child(3) > tr:nth-child(#{row}) > td:nth-child(2) > a:nth-child(1)").text.strip.scan(/\d+/).first.to_i

        p "speed >>> #{speed}"
        anonymity = doc.css(".layui-table > tbody:nth-child(3) > tr:nth-child(#{row}) > td:nth-child(7) > a:nth-child(1)").text.strip

        p "anonymity >>>> #{anonymity}"
        protocol = doc.css(".layui-table > tbody:nth-child(3) > tr:nth-child(#{row}) > td:nth-child(6) > a:nth-child(1)").text.strip

        p "protocol >>>> #{protocol}"
        ip_address = doc.css(".layui-table > tbody:nth-child(3) > tr:nth-child(#{row}) > td:nth-child(1)").text.strip

        p "ip_address >>>> #{ip_address}"
        port = doc.css(".layui-table > tbody:nth-child(3) > tr:nth-child(#{row}) > td:nth-child(2) > a:nth-child(1)").text.strip

        p "port >>>> #{port}"
        # Verifica se todos os componentes do proxy estão presentes antes de montar a string

        if speed > 500 && anonymity == 'High' && (protocol == 'socks5' || protocol == 'http')
          best_proxy = "#{protocol}://#{ip_address}:#{port}"
          proxys_list.push(best_proxy)
          p "best_proxy 1 >>> #{best_proxy}"
        elsif speed > 500 && anonymity == 'High' && (protocol == 'socks5' || protocol == 'http')
          best_proxy = "#{protocol}://#{ip_address}:#{port}"
          proxys_list.push(best_proxy)
          p "best_proxy 2 >>> #{best_proxy}"
        elsif speed > 200 && anonymity == 'High' && (protocol == 'socks5' || protocol == 'http')
          best_proxy = "#{protocol}://#{ip_address}:#{port}"
          proxys_list.push(best_proxy)
        elsif speed > 200 && anonymity == 'High' && (protocol == 'socks5' || protocol == 'http')
          best_proxy = "#{protocol}://#{ip_address}:#{port}"
          proxys_list.push(best_proxy)
        elsif speed > 10 && anonymity == 'High' && (protocol == 'socks5' || protocol == 'http')
          best_proxy = "#{protocol}://#{ip_address}:#{port}"
          proxys_list.push(best_proxy)
        end

        p "proxy_length >>>>>>> #{proxys_list.length}"
        
        row += 1
      end

      return proxys_list
    end
  end
end
