library(BatchGetSymbols)

# set dates
last.date <- as.Date("2016-12-31")
first.date <- as.Date("2011-12-31")

# set tickers
tickers = read.csv("C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/russel3000matches.csv", header = FALSE, stringsAsFactors = F)[[1]]

l.out <- BatchGetSymbols(tickers = tickers, 
                         first.date = first.date,
                         last.date = last.date, 
                         cache.folder = file.path(tempdir(), 
                                                  'BGS_Cache') ) # cache in tempdir()

# Take only tickers with 100% of data in the past 5 years
okTickers = as.character(l.out$df.control$ticker[l.out$df.control$perc.benchmark.dates==1])
p = length(okTickers) #1018
write.csv(l.out$df.tickers, "C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/ALLDATA.csv", row.names = F)
write.csv(l.out$df.control, "C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/CONTROL.csv", row.names = F)
#rTickers = okTickers[sample(x = 1:p, size = 500, replace = F)]
#write.csv(rTickers, "C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/rTickers.csv", row.names = F)
rTickers = read.csv("C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/rTickers.csv", stringsAsFactors = F)[[1]]
rp = 500

data = l.out$df.tickers[, c(8, 7, 9)][l.out$df.tickers$ticker%in%rTickers,]
n = nrow(data[data$ticker==rTickers[1],]) - 1 #1257
dates = data[data$ticker==rTickers[1], "ref.date"]

# Initialise returns data
returnsdata = data.frame(matrix(numeric(n*rp), n, rp))
names(returnsdata) = rTickers
for(i in 1:rp){
  temp = data[data$ticker == rTickers[i],]
  ret.temp = temp$ret.adjusted.prices
  ret = ret.temp[2:1258]
  returnsdata[, i] = ret
}

write.csv(returnsdata, "C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/returnsdata.csv", row.names = F)

# Returns with dates
returns = cbind.data.frame(dates[2:1258], returnsdata)
names(returns) = c("date", rTickers)
write.csv(returns, "C:/Users/Jer/Google Drive/NTU/NTU Year 4 Sem 2/FYP/Russel 3000/returns.csv", row.names = F)

# Check
anyNA(returnsdata)
anyNA(returns)
