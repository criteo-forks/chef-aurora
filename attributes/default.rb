# encoding: utf-8

# The package version needs to be specified for RHEL platforms
# We use the latest version available for debian platforms
default['aurora']['version'] = case node['platform_family']
    when 'rhel' then '0.12.0-1'
    else ''
end

# Installation method can be either:
# * 'rpm' to install Aurora packages directly from RPM files
# * 'yum' to install Aurora packages from a yum repository
# Additional options can be set to the package provider
default['aurora']['package']['rhel'] = {
  install_method: 'rpm',
  options: nil
}

# Aurora configuration files are platform dependant
default['aurora']['config_files']['scheduler'] = case node['platform_family']
    when 'debian' then '/etc/default/aurora-scheduler'
    when 'rhel'   then '/etc/sysconfig/aurora'
    else raise "Platform family #{node['platform_family']} not supported"
end
default['aurora']['config_files']['thermos_observer'] = case node['platform_family']
    when 'debian' then '/etc/default/thermos'
    when 'rhel'   then '/etc/sysconfig/thermos-observer'
    else raise "Platform family #{node['platform_family']} not supported"
end

# Aurora services names are platform dependant
default['aurora']['services']['scheduler'] = case node['platform_family']
    when 'debian' then 'aurora-scheduler'
    when 'rhel'   then 'aurora'
    else raise "Platform family #{node['platform_family']} not supported"
end
default['aurora']['services']['thermos_observer'] = case node['platform_family']
    when 'debian' then 'thermos'
    when 'rhel'   then 'thermos-observer'
    else raise "Platform family #{node['platform_family']} not supported"
end

# These thermos parameters are used to generate the value of
# -thermos_executor_flags="..." for the aurora scheduler.
default['aurora']['thermos'] = {
  # Enable service announcements?
  announcer_enable: true,

  # zookeeper ensemble and base path for service announcements:
  zk_announce_endpoints: 'localhost:2181',
  zk_announce_path: '/aurora/svc'
}
# Other arguments of --thermos_executor_flags can also be passed
# directly
default['aurora']['scheduler']['app_config']['thermos_executor_flags'] = ''

default['aurora']['client'] = [
  {
    name: "test-cluster",
    scheduler_uri: "http://localhost:55555",
  }
]

# thermos-observer config
default['aurora']['thermos_observer'] = {
  port: '1338',
  log_to_disk: 'NONE',
  log_to_stderr: 'google:INFO'
}

# Should Chef automatically initialize the replicated log?
#
# CAUTION: you only want to do this on the first scheduler node in a new
#          cluster or you could lose *all* of your aurora state. RTFM!
#
default['aurora']['scheduler']['autoinit_db'] = false

default['aurora']['scheduler']['glob_opts'] = {
  # libmesos logging verbosity
  'GLOG_v' => '0',
  # Port used to register the framework with the mesos master
  'LIBPROCESS_PORT' => '8083',
}

default['aurora']['scheduler']['java_opts'] = [
  '-server',
  # Mesosphere debs put mesos libraries in /usr/local/lib
  '-Djava.library.path=/usr/local/lib'
]

default['aurora']['scheduler']['app_config'] = {
  # The name of this cluster.
  cluster_name: 'example',

  # The HTTP port upon which Aurora will listen.
  http_port: '8081',

  # The ZooKeeper quorum to which Aurora will register itself.
  # Comma-delimited list of host:ports
  zk_endpoints: 'localhost:2181',

  # The ZooKeeper URL of the ZNode where the Mesos master has registered.
  mesos_master_address: 'zk://localhost:2181/mesos',

  # The ZooKeeper ZNode within the specified quorum to which Aurora
  # will register its ServerSet, which keeps track of all live Aurora
  # schedulers.
  serverset_path: '/aurora/scheduler',

  # URL to thermos executor (or wrapper script), or a path on the slaves
  thermos_executor_path: '/usr/share/aurora/bin/thermos_executor.pex',

  # A comma seperated list of additional resources to copy into the sandbox.
  # Note: if thermos_executor_path is not the thermos_executor.pex file itself,
  # this must include it.
  thermos_executor_resources: '',

  # Allows the scheduling of containers of the provided type.
  allowed_container_types: 'MESOS,DOCKER',

  # Size of the quorum of Aurora schedulers which possess a native
  # log.  If running in multi-master mode, consult the following
  # document to determine appropriate values:
  #
  # https://aurora.apache.org/documentation/latest/deploying-aurora-scheduler/#replicated-log-configuration
  # IMPORTANT: Set to (floor(NumberOfSchedulers/2) + 1)
  native_log_quorum_size: 1, # former quorum_size
  # The ZooKeeper ZNode to which Aurora will register the locations of
  # its replicated log.
  native_log_zk_group_path: '/aurora/replicated-log', # former zk_logdb
  # The local directory in which an Aurora scheduler can find Aurora's
  # replicated log.
  native_log_file_path: '/var/lib/aurora/scheduler/db',
  # The local directory in which Aurora schedulers will place state
  # backups.
  backup_dir: '/var/lib/aurora/scheduler/backups',

  # Authentication file
  framework_authentication_file: '/etc/aurora-mesos-creds',

  # HTTP Basic Authentication (source: http://aurora.apache.org/documentation/latest/operations/security/#http-basic-authentication)
  #http_authentication_mechanism: 'BASIC',
  #shiro_realm_modules: 'INI_AUTHNZ',
  #shiro_ini_path: '/etc/aurora/security.ini',
}

default['aurora']['scheduler']['mesos_creds'] = {
  aurora_authentication_principal: 'aurora',
  aurora_authentication_secret: 'test'
}

default['aurora']['scheduler']['security']['admins']= {'sally' => 'apple'}

# Set this to false if you don't want to add apt.folsomlabs.com/aurora to your
# system. You will need to have the aurora debs available by some other means
# in that case, presumably from your own repo.
default['aurora']['use_folsomlabs_apt_repo'] = true

# Is it cool for the scheduler recipe to install java?
default['aurora']['install_java'] = true

# Aurora 0.9.0 onwards will require Java version 8
default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = '8'
default['java']['oracle']['accept_oracle_download_terms'] = true
