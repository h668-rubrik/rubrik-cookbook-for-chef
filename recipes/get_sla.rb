#
# Cookbook:: rubrik
# Recipe:: get_sla
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Pulls out information on the current SLA for the host
#
rubrik_set_sla 'get' do
  action :get
end
