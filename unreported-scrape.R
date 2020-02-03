#install.packages(c("rvest","rowr"))
library(rvest)
library(rowr)

## PROGRAM TO PULL ALL UNREPORTED BILLS CONSIDERED BY HOUSE

i = 1

webpage <- read_html(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:7000+NOT+5000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))

iterations <- as.numeric(gsub("\\D", "", paste(html_nodes(webpage,xpath="//div[@class='pagination']//span[@class='results-number']/text()"))))

sumdata <- data.frame("Measure" = NA, "Latest" = NA, "Congress" = NA, "Legislation Title" = NA,"Date Introduced" = NA,"House or Senate" = NA)

while(i <= iterations) {
  webpage <- read_html(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:7000+NOT+5000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
  df <- data.frame("Measure" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a//text()")),
                   "Latest" = paste(html_nodes(webpage,xpath="//*//li[@class='compact']//span[@class='result-item'][./strong='Latest Action:']/span[1]/text()[1]")),
                   "Congress" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a/following-sibling::text()")),
                   "Legislation Title" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-title bottom-padding']//text()")),
                   "Date Introduced" = paste(html_nodes(webpage, xpath="//div[@id='main']//li[@class='compact']//span[@class='result-item'][1]/span[1]/a[1]/following-sibling::text()[1]")),
                   "House or Senate" = "House")
  sumdata <- rbind(sumdata,df)
  df <- NULL
  i = i + 1
  Sys.sleep(10)
}

## PROGRAM TO PULL ALL UNREPORTED BILLS CONSIDERED BY SENATE

i = 1
webpage <- read_html(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:16000+NOT+14000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
iterations <- as.numeric(gsub("\\D", "", paste(html_nodes(webpage,xpath="//div[@class='pagination']//span[@class='results-number']/text()"))))

while(i <= iterations) {
  webpage <- read_html(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:16000+NOT+14000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
  df <- data.frame("Measure" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a//text()")),
                   "Latest" = paste(html_nodes(webpage,xpath="//*//li[@class='compact']//span[@class='result-item'][./strong='Latest Action:']/span[1]/text()[1]")),
                   "Congress" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a/following-sibling::text()")),
                   "Legislation Title" = paste(html_nodes(webpage,xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-title bottom-padding']//text()")),
                   "Date Introduced" = paste(html_nodes(webpage, xpath="//div[@id='main']//li[@class='compact']//span[@class='result-item'][1]/span[1]/a[1]/following-sibling::text()[1]")),
                   "House or Senate" = "Senate")
  sumdata <- rbind(sumdata,df)
  df <- NULL
  i = i + 1
  Sys.sleep(10)
}