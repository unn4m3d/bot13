#!/usr/bin/ruby
$home = File.dirname(File.expand_path(__FILE__))

module ExitCodes
	OK 			= 0
	LIBMISSING	= 1
	INTERNALERR = 2
	INVALIDCFG  = 3
end

module Bot13
	VERSION = "3.4 Tg Edition"
end
require 'optparse'
require 'json'

$options = {}


begin
	puts "[INFO] Loading Bot-Th1rt3en v#{Bot13::VERSION}"
	OptionParser.new do |o|
		o.banner = "Bot-Th1rt3en v#{Bot13::VERSION}"
		o.on('-HHOME','--home=HOME','Change home'){|h| $home=h}
		o.on('-f','--failsafe','Catch exceptions with restart'){$options[:f] = true}
		o.on('-h','--help','Print this help'){puts o; exit 0}
		o.on('-dLEVEL','--debug=LEVEL','Minimal message level'){|l|$options[:d]=l.to_i}
		o.on('-tTOKEN','--token=TOKEN','Set token'){|t|$options[:t]=t}
	end.parse!

	unless File.exists?(File.join($home,'lib','debug.rb'))
		puts '[FATAL] Cannot load library lib/debug.rb'
		exit ExitCodes::LIBMISSING
	end

	require File.join($home,'lib','debug')

	dinfo "Debug library loaded successfully"

	lib 'lib/load'
	#lib 'lib/tgapi'
	lib 'lib/plugins'
	#lib 'lib/cmdengine'
	lib 'lib/storage'
	lib 'lib/perms'
	lib 'lib/bot'

	def restart
		puts '[INFO] Restart!'
		begin
			_ul
		ensure
			exec "#{__FILE__} #{ARGV.join ' '}"
		end
	end

	config = JSON.parse File.read File.join($home,'data/config.json')


	unless config['token'] or $options[:t]
		dfatal "No token specified"
		exit ExitCodes::INVALIDCFG
	end

	unless File.exists?(File.join($home,"temp"))
		Dir.mkdir(File.join($home,"temp"))
		dinfo "Creating directory temp/"
	end


	token = ($options[:t] || config['token'])

	bot = Bot13::Bot.new(
		token,
		home: $home,
		failsafe: $options[:f],
		config: config
	)

	bot.start


rescue => e
	puts "[FATAL] #{(e.class.name.gsub(/([A-Z])/){"_#{$1}"}).upcase.gsub(/::/,'_')}"
	if $options[:f] and not e.kind_of? LoadError then #Restart if failsafe mode enabled and this is not a LoadError
			restart
	else
			_ul
			raise e
	end
end

_ul
