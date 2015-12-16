Puppet::Type.type(:package).provide(:tdagent, parent: :gem, source: :gem) do
  commands gemcmd: '/opt/td-agent/usr/sbin/td-agent-gem'
end
