# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "csv"
require "#{Rails.root}/lib/source_job.rb"

APP_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/settings.yml")).result)[Rails.env]

ActiveSupport::XmlMini.backend = 'LibXML'
 
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  if payload[:controller] == "Api::V3::ArticlesController"
    ApiRequest.create! do |page_request|
      page_request.path = payload[:path]
      page_request.format = payload[:format] || "html"
      page_request.page_duration = (finish - start) * 1000
      page_request.view_duration = payload[:view_runtime]
      page_request.db_duration = payload[:db_runtime]
    end
  end
end