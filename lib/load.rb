$load = []
$unload = []

# Add block to load query
#
# @param [Block] b Block to execute
# @example Load
# 	load { puts "Hello, World!"}
def load(&b)
	$load.push b if block_given?
end

# Add block to unload query
#
# @param [Block] b Block to execute
def unload(&b)
	$unload.push b if block_given?
end

# Call block
#
# @param [Object] a Argument
# @param [Block] b Block to execute
# @api private
def _c(a=nil,&b)
	yield a if a and block_given?
	yield if block_given?
end

# Execute load query
#
# @param [Array] blocks Array of blocks
# @param [String] label Label (name of execution place)
# @param [Hash] cfg Config to load
# @api private
def _ld(blocks=$load,label=nil,cfg={})
	blocks.each_with_index do |v,i|
		if self.class.method_defined? :dinfo then
			dinfo "Loading block #{i+1}/#{blocks.size} from #{label}" if label
		else
			puts "[INFO] Loading block #{i+1}/#{blocks.size} from #{label}" if label
		end
		_c cfg,&v
	end
end


# Execute unload query
#
# @param [Array] blocks Array of blocks
# @param [String] label Label (name of execution place)
# @api private
def _ul(blocks=$unload,label=nil)
	blocks.each_with_index do |v,i|
		if self.class.method_defined? :dinfo then
			dinfo "Unloading block #{i+1}/#{blocks.size} from #{label}" if label
		else
			puts "[INFO] Unloading block #{i+1}/#{blocks.size} from #{label}" if label
		end
		_c &v
	end
end

