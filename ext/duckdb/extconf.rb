# frozen_string_literal: true

require 'mkmf'

DUCKDB_REQUIRED_VERSION = '1.2.0'

def check_duckdb_header(header, version)
  found = find_header(
    header,
    '/usr/local/include',              # Standard Linux location
    '/usr/include',                    # System Linux location
    '/opt/homebrew/include',           # Keep macOS Homebrew on Apple Silicon
    '/opt/homebrew/opt/duckdb/include', # Keep macOS Homebrew DuckDB formula
    '/opt/local/include',              # Keep macOS MacPorts
    '/usr/local/opt/duckdb/include'    # Additional potential location
  )
  return if found

  msg = "#{header} is not found. Install #{header} of duckdb >= #{version}."
  print_message(msg)
  raise msg
end

def check_duckdb_library(library, func, version)
  found = find_library(
    library,
    func,
    '/usr/local/lib',                  # Standard Linux location
    '/usr/lib',                        # System Linux location
    '/opt/homebrew/lib',               # Keep macOS Homebrew on Apple Silicon
    '/opt/homebrew/opt/duckdb/lib',    # Keep macOS Homebrew DuckDB formula
    '/opt/local/lib',                  # Keep macOS MacPorts
    '/usr/local/opt/duckdb/lib'        # Additional potential location
  )
  have_func(func, 'duckdb.h')
  return if found

  raise_not_found_library(library, version)
end

def raise_not_found_library(library, version)
  library_name = duckdb_library_name(library)
  msg = "#{library_name} is not found. Install #{library_name} of duckdb >= #{version}."
  print_message(msg)
  raise msg
end

def duckdb_library_name(library)
  "lib#{library}.#{RbConfig::CONFIG['DLEXT']}"
end

def print_message(msg)
  print <<~END_OF_MESSAGE

    #{'*' * 80}
    #{msg}
    #{'*' * 80}

  END_OF_MESSAGE
end

dir_config('duckdb')

check_duckdb_header('duckdb.h', DUCKDB_REQUIRED_VERSION)
check_duckdb_library('duckdb', 'duckdb_create_instance_cache', DUCKDB_REQUIRED_VERSION)

# check duckdb >= 1.2.0
have_func('duckdb_create_instance_cache', 'duckdb.h')

# check duckdb >= 1.3.0
have_func('duckdb_get_table_names', 'duckdb.h')

$CFLAGS << ' -DDUCKDB_API_NO_DEPRECATED' if ENV['DUCKDB_API_NO_DEPRECATED']

create_makefile('duckdb/duckdb_native')
