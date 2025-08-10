require "rake/testtask"

# Default task
task default: :test

# Test task Config
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/**/test_*.rb"]
  t.verbose = true
end

# Integration tests only
Rake::TestTask.new(:test_integration) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/integration/**/test_*.rb"]
  t.verbose = true
end

# Unit tests only
Rake::TestTask.new(:test_unit) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/lib/**/test_*.rb"]
  t.verbose = true
end
