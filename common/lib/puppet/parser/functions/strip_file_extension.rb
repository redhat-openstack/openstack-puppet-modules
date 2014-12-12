module Puppet::Parser::Functions
  newfunction(:strip_file_extension, :type => :rvalue, :doc => <<-EOS
    Takes two arguments, a file name which can include the path, and the
    extension to be removed. Returns the file name without the extension
    as a string.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "strip_file_extension(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2

    filename = args[0]

    # allow the extension to optionally start with a period.
    if args[1] =~ /^\./
      extension = args[1]
    else
      extension = ".#{args[1]}"
    end

    File.basename(filename,extension)
  end
end
