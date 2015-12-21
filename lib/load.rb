$load = []
$unload = []

def load(&b)
	$load.push b if block_given?
end

def unload(&b)
	$unload.push b if block_given?
end

def _c(a=nil,&b)
	yield a if a and block_given?
	yield if block_given?
end

def _ld(blocks=$load,label=nil,cfg={})
	blocks.each_with_index do |v,i|
		puts "Loading block #{i+1}/#{blocks.size} from #{label}" if label
		_c cfg,&v
	end
end

def _ul(blocks=$unload,label=nil)
	blocks.each_with_index do |v,i|
		puts "Unloading block #{i+1}/#{blocks.size} from #{label}" if label
		_c &v
	end
end

