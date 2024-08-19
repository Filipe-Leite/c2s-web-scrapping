import sys
import json
from scrapfly import ScrapflyClient, ScrapeConfig

def main(url):
    try:
        # Configurar o cliente Scrapfly
        scrapfly = ScrapflyClient(key="YOUR_SCRAPFLY_API_KEY")
        
        # Configuração para o scraping
        config = ScrapeConfig(
            url=url,
            asp=True,
            render_js=True,
            country="JP",
            proxy_pool=ScrapeConfig.PUBLIC_RESIDENTIAL_POOL
        )
        
        # Executar o scraping
        result = scrapfly.scrape(config)
        
        # Processar o resultado
        scraping_result = result.scrape_result
        
        # Converta o resultado para JSON e imprima
        print(json.dumps(scraping_result))
    except Exception as e:
        print(json.dumps({'error': str(e)}), file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python scrape.py <URL>")
        sys.exit(1)
    url = sys.argv[1]
    main(url)
