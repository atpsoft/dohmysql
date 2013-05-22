module DohDb
module Migrate
COMMAND_INFO = [
['make', '<name>', 'creates the files for a new migration'],
['check', '<name>', 'checks that all migrations are valid'],
['commit', '<name>', 'UNIMPLEMENTED: executes the check command, then git add,commit'],
['apply', '<name>', 'applies one or more migrations'],
['revert', '<name>', 'reverts one or more migrations'],
['verify' ,'<name>', 'verifies that the migration has been integrated into the base files'],
['merge', '<name>', 'UNIMPLEMENTED: executes the verify command, then git rm,commit'],
].freeze
COMMANDS = COMMAND_INFO.collect {|name, args, desc| name}.freeze
NOTIFY_COMMANDS = %w(apply revert)

cmd_detail = COMMAND_INFO.collect do |name, args, desc|
  args = ' ' + args unless args.empty?
  name_rpad = ' ' * (33 - (name.size + args.size))
  "    #{name}#{args}#{name_rpad}#{desc}"
end.join("\n")

OPTS = Doh::Options.new(
{'database' => [Doh.config[:default_database], "-d", "--database <database>", "name of the database to migrate -- defaults to config[:default_database], currently '#{Doh.config[:default_database]}'"] \
, 'runafter' => [false, "-a", "--after", "for migrate make, creates the migrations designed to be run after a deploy (defaults to before)"] \
}, true, "Commands:\n\n#{cmd_detail}")

CMD_NAME, CMD_ARGS = OPTS.varargs.shift, OPTS.varargs
unless COMMANDS.include?(CMD_NAME)
  warn "unrecognized command #{cmd_name}"
  exit 1
end

if OPTS.database.to_s.empty?
  warn "You must specify a database, either here with -d or in config"
  exit 1
end

def self.cmd_name_and_args
  [OPTS, CMD_NAME, CMD_ARGS]
end

end
end
