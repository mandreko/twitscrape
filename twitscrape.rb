#Twitscrape.rb v1.0
#Twitter Trending Topics Scraping Tool
#Coded by Luis Santana
#HackTalk Security Team
#Shouts to Shardy, Rage, Node, Xires & Stacy, Pure_Hate, J0hnnyBrav0

# Let's get the required gems
require "rubygems"
require "mechanize"
require "work_queue"
require "progressbar"
require "json"
require "uri"

Mechanize::Util::CODE_DIC[:SJIS] = "UTF-8" # Ensuring we have UTF-8 Support

puts "****************************************"
puts "*             Twitscrape.rb            *"
puts "*               Coded By               *"
puts "*             Luis Santana             *" 
puts "*           HackTalk Security          *"
puts "****************************************"

time = Time.new

# Let's create our signature "database"
sigs = Array['//div[@class="tweet-text"]']
dump = File.open("twitterTrends_scrape#{time.day}-#{time.month}-#{time.year}.txt", "w") # Creating our file to dump usernames into

# Setting up Mechanize
agent = Mechanize.new
agent.user_agent_alias = "Windows Mozilla"

# Let's go login!!!!
#user = 'username'
#pass = 'password'

page = agent.get("https://mobile.twitter.com/session/new")
login_form = page.forms[0]
login_form['username'] = user
login_form['password'] = pass
page = agent.submit(login_form)

page = agent.get("https://api.twitter.com/1/trends/1.json")

# Let's grab the trends
trends = Array.new
rawTrend = JSON.parse(page.body)[0]['trends']
rawTrend.each do |index|
	trends.push(index['name'])
end

# Get our threadpool started with 50 threads with a max of 25 threads which can be waiting in the queue
wq = WorkQueue.new(50,25)

words = Array.new # Create array to hold words so that we don't potentially deadlock the dump file during writes

puts "[+] Now Scraping Please Wait"
#pbar = ProgressBar.new("Scrape Process", 210) # Start our progress bar

# Start the pwnage
trends.each do |trend|
	wq.enqueue_b {
    		page = agent.get("http://mobile.twitter.com/search/#{URI.escape(trend)}")
		sigs.each do |sig|
                        page.search(sig).each do |tweet|
					words.push("#{tweet.inner_text}")
       			end
		end
	}
	#pbar.set()
	wq.join
end
# Finish off progress bar
#pbar.finish

# Sort all tweets in the words array
words.sort!

# Now let's split the array into single words and unique them
#singleWords = Array.new
#words.each do |word|
#	singleWords.push("#{word.split(/\W+/)}")
#end

#singleWords.sort!

# Save all sorted usernames into the dump file and print a closing message 
dump.puts(words.join("\n"))
#dump.puts(singleWords.join.gsub('"', ''))

puts "\nFinished Scraping"