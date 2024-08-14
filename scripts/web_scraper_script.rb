require 'nokogiri'
require 'open-uri'

url = 'https://www.selenium.dev/documentation/webdriver/waits/'

html_content = URI.open(url)

doc = Nokogiri::HTML(html_content)

begin
  # Usando XPath para selecionar os elementos
  brand_element = doc.at_xpath('//*[@id="implicit-waits"]')
  brand = brand_element ? brand_element.text.strip : 'Marca não encontrada'

  model_element = doc.at_xpath('//*[@id="implicit-waits"]')
  model = model_element ? model_element.text.strip : 'Modelo não encontrado'
  
  price_element = doc.at_xpath('//*[@id="implicit-waits"]')
  price = price_element ? price_element.text.strip : 'Preço não encontrado'

  puts "Marca: #{brand}"
  puts "Modelo: #{model}"
  puts "Preço: #{price}"

rescue StandardError => e
  puts "Ocorreu um erro: #{e.message}"
end