#install.packages(c("rvest","rowr","openxlsx","httr"))
library(rvest)
library(rowr)
library(openxlsx)
library(httr)

## PROGRAM TO PULL ALL UNREPORTED BILLS CONSIDERED BY HOUSE

i = 1

webpage <- GET(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:7000+NOT+5000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))

iterations <- as.numeric(gsub("\\D", "", paste(html_nodes(content(webpage),xpath="//div[@class='pagination']//span[@class='results-number']/text()"))))

sumdata <- data.frame("Measure" = NA, "Latest" = NA, "Congress" = NA, "Legislation Title" = NA,"Date Introduced" = NA,"House or Senate" = NA)


while(i <= iterations) {
  webpage <- GET(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:7000+NOT+5000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
  df <- cbind.fill(paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']/span[@class='result-heading']/a/text()")),
                   paste(html_nodes(content(webpage),xpath="//*//li[@class='compact']//span[@class='result-item'][./strong='Latest Action:']/span[1]/text()[1]")),
                   paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a/following-sibling::text()")),
                   paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-title bottom-padding']//text()")),
                   paste(html_nodes(content(webpage), xpath="//div[@id='main']//li[@class='compact']//span[@class='result-item'][1]/span[1]/a[1]/following-sibling::text()[1]")),
                   fill = NA)
                   
  df <- cbind.fill(df,
                   "House")
  colnames(df) <- c("Measure","Latest","Congress","Legislation.Title","Date.Introduced","House.or.Senate")
  sumdata <- rbind(sumdata,df)
  df <- NULL
  i = i + 1
  Sys.sleep(30)
} 

## PROGRAM TO PULL ALL UNREPORTED BILLS CONSIDERED BY SENATE
save <- sumdata

i = 1
webpage <- GET(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:16000+NOT+14000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
iterations <- as.numeric(gsub("\\D", "", paste(html_nodes(content(webpage),xpath="//div[@class='pagination']//span[@class='results-number']/text()"))))

while(i <= iterations) {
  webpage <- GET(paste("https://www.congress.gov/advanced-search/command-line?query=actionCode:16000+NOT+14000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&pageSize=250","&page=",i,sep=""))
  df <- cbind.fill(paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']/span[@class='result-heading']/a/text()")),
                   paste(html_nodes(content(webpage),xpath="//*//li[@class='compact']//span[@class='result-item'][./strong='Latest Action:']/span[1]/text()[1]")),
                   paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-heading']//a/following-sibling::text()")),
                   paste(html_nodes(content(webpage),xpath="//*//ol[@class='basic-search-results-lists expanded-view']//li[@class='compact']//span[@class='result-title bottom-padding']//text()")),
                   paste(html_nodes(content(webpage), xpath="//div[@id='main']//li[@class='compact']//span[@class='result-item'][1]/span[1]/a[1]/following-sibling::text()[1]")),
                   fill = NA)
  
  df <- cbind.fill(df,
                   "Senate")
  colnames(df) <- c("Measure","Latest","Congress","Legislation.Title","Date.Introduced","House.or.Senate")
  sumdata <- rbind(sumdata,df)
  df <- NULL
  i = i + 1
  Sys.sleep(30)
}


housedata <- subset(sumdata,grepl("House",sumdata$House.or.Senate,fixed=TRUE))
senatedata <- subset(sumdata,grepl("Senate",sumdata$House.or.Senate,fixed=TRUE))

l = c(116:100,'99th',"98th","97th","96th","95th","94th","93rd")
i = 1
results = as.data.frame(matrix(nrow=len(na.omit(unique(sumdata$Congress))),ncol=3))

while(i <= len(l)){
  results[i,1] <-  l[i]
  results[i,2] <-  len(subset(housedata,grepl(l[i],housedata$Congress,fixed=TRUE)))
  results[i,3] <-  len(subset(senatedata,grepl(l[i],senatedata$Congress,fixed=TRUE)))
  i = i + 1
}


webpage = GET("https://www.congress.gov/advanced-search/command-line?query=actionCode:7000&searchResultViewType=compact&q={%22type%22:[%22bills%22,%22joint-resolutions%22]}&KWICView=false")
path = "//div[@id='facetbox_congress']//li[@class='facetbox-shownrow']//label//a/span[@class='count']/text()"
results <- cbind.fill(results,as.data.frame(paste(html_nodes(content(webpage),xpath=path))),fill=NA)

webpage = GET("https://www.congress.gov/advanced-search/command-line?query=actionCode%3A16000&searchResultViewType=compact&q=%7B%22type%22%3A%5B%22bills%22%2C%22joint-resolutions%22%5D%7D")
results <- cbind.fill(results,as.data.frame(paste(html_nodes(content(webpage),xpath=path))),fill=NA)

colnames(results) <- c("Congress","House Unreported Bills","Senate Unreported Bills","Total Bills Considered by House","Total Bills Considered by Senate")
copy <- results
results<-copy


hold<- data.frame(paste(gsub("[^0-9.-]", "", results$`Total Bills Considered by House`)))
results$`Total Bills Considered by House` <- hold

hold <- data.frame(gsub("[^0-9.-]", "", results$`Total Bills Considered by Senate`))
results$`Total Bills Considered by Senate` <- hold

colnames(results) <- c("Congress","House Unreported Bills","Senate Unreported Bills","Total Bills Considered by House","Total Bills Considered by Senate")

#save to excel

wb = loadWorkbook("C:/Users/rorey/OneDrive - Bipartisan Policy Center/Congress/Modernization/Committee Consideration/unreported-scrape-results.xlsx")
writeData(wb,"All Results",sumdata)
writeData(wb,"Analysis",results)
saveWorkbook(wb,"C:/Users/rorey/OneDrive - Bipartisan Policy Center/Congress/Modernization/Committee Consideration/unreported-scrape-results.xlsx",overwrite=TRUE)

