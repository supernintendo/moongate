use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"U1c!Ow3OJjf!n(9sV,VbZPj5ewE:P7t{z:v_4;614FD$2)n=wjzv=,uH$pSIWIv}"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"i1yyB6[6}3]]d@eD1=JYk<UYW9JOMuFdnm7*q(4W.ebY8Q^0XP^pa7TQincSgItk"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :moongate do
  set version: current_version(:moongate)
end