# frozen_string_literal: true

require 'cocoapods'
require 'cocoapods/validator'

module LHToolsCocoaPodsLintDeploymentTargetPatch
  def podfile_from_spec(*args)
    podfile = super
    minimum_target = ENV.fetch('COCOAPODS_LINT_DEPLOYMENT_TARGET', '13.0')
    minimum_version = Gem::Version.new(minimum_target)

    podfile.post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          current = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
          next if current && Gem::Version.new(current) >= minimum_version

          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = minimum_target
        end
      end
    end

    podfile
  end
end

Pod::Validator.prepend(LHToolsCocoaPodsLintDeploymentTargetPatch)
