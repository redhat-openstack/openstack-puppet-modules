
Puppet::Type.newtype(:remote_database_user) do
  @doc = "Manage a database user remotely. This includes management of users password as well as priveleges"

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # If at least one special char is used, string must be quoted

      # http://stackoverflow.com/questions/8055727/negating-a-backreference-in-regular-expressions/8057827#8057827
      if matches = /^(['`"])((?:(?!\1).)*)\1@([\w%\.:\-]+)/.match(value)
        user_part = matches[2]
        host_part = matches[3]
      elsif matches = /^([0-9a-zA-Z$_]*)@([\w%\.:\-]+)/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      elsif matches = /^((?!['`"]).*[^0-9a-zA-Z$_].*)@(.+)$/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      else
        raise(ArgumentError, "Invalid database user #{value}")
      end

      raise(ArgumentError, 'MySQL usernames are limited to a maximum of 16 characters') if user_part.size > 16
    end

    munge do |value|
      matches = /^((['`"]?).*\2)@([\w%\.:\-]+)/.match(value)
      "#{matches[1]}@#{matches[3].downcase}"
    end
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mysql_password() for creating such a hash."
    newvalue(/\w+/)
  end

  newparam(:db_host) do
    desc "The hostname of the database server to connect."
  end

  newparam(:db_user) do
    desc "The user name to use when connecting to the server."
  end

  newparam(:db_password) do
    desc "The password with which to connect to the database server."
  end

end
