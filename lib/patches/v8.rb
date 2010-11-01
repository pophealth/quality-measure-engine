# Patching V8::Object because it is the entry point for conversions
# between Ruby and JavaScript types. We are using seconds since the
# epoch to represent dates. On 32 bit architectures, for recent dates
# this will be too large for Fixnum and become a Bignum. Ruby Racer
# worn't properly convert a Bignum to JavaScript, but it will work
# just fine for a Float. Because of this, we will convert all Bignums
# passed into a JavaScript context to a Float
module V8
  class Object
    alias :old_index_setter :'[]='
    
    def []=(key, value)
      if value.kind_of?(Bignum)
        old_index_setter(key, value.to_f)
      else
        old_index_setter(key, value)
      end
    end
  end
end