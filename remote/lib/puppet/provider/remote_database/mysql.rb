Puppet::Type.type(:remote_database).provide(:mysql) do

  desc "Manages remote MySQL / MariaDB database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    mysql([
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      '-NBe',
      'show databases'
    ]).split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql([
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      '-NBe',
      "create database `#{@resource[:name]}` character set #{@resource[:charset]} collate #{@resource[:collate]}"
    ])
  end

  def destroy
    mysqladmin(
        "--host=#{@resource[:db_host]}",
        "--user=#{@resource[:db_user]}",
        "--password=#{@resource[:db_password]}",
        '-f',
        'drop', @resource[:name]
    )
  end

  def charset
    mysql(
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      "-NBe",
      "show create database `#{resource[:name]}`").match(/.*?(\S+)\s\*\//
    )[1]
  end

  def charset=(value)
    mysql(
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      "-NBe",
      "alter database `#{resource[:name]}` character set #{value}"
    )
  end

  def collate
    mysql(
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      "-NBe",
      "use #{resource[:name]}; show variables like 'collation_database'"
    ).match(/\s*collation_database\s+(\S+)/)[1]
  end

  def collate=(value)
    mysql(
      "--host=#{@resource[:db_host]}",
      "--user=#{@resource[:db_user]}",
      "--password=#{@resource[:db_password]}",
      "-NBe",
      "alter database `#{resource[:name]}` collate #{value}"
    )
  end

  def exists?
    begin
      mysql(
        "--host=#{@resource[:db_host]}",
        "--user=#{@resource[:db_user]}",
        "--password=#{@resource[:db_password]}",
        "-NBe",
        "show databases"
      ).match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end

end
