# Adds the DueWidget WidgetKit extension to app/ios/Runner.xcodeproj and
# embeds it in Runner. Idempotent: running it again changes nothing.
#
#   gem install xcodeproj
#   ruby tool/ios/add_widget_target.rb

require 'xcodeproj'

ROOT = File.expand_path('../..', __dir__)
PROJECT = File.join(ROOT, 'app/ios/Runner.xcodeproj')
NAME = 'DueWidget'
BUNDLE_ID = 'dev.avi.due.DueWidget'
DEPLOYMENT = '17.0'
FONTS = %w[
  BricolageGrotesque-500 BricolageGrotesque-600 BricolageGrotesque-700
  HankenGrotesk-400 HankenGrotesk-600 JetBrainsMono-400 JetBrainsMono-600
].freeze

project = Xcodeproj::Project.open(PROJECT)
runner = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target missing'

# The app joins the App Group the widget reads from.
runner.build_configurations.each do |c|
  c.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
runner_group = project.main_group['Runner']
unless runner_group.files.any? { |f| f.path == 'Runner.entitlements' }
  runner_group.new_file('Runner.entitlements')
end

if project.targets.any? { |t| t.name == NAME }
  project.save
  puts "#{NAME} already present; Runner entitlements checked."
  exit
end

widget = project.new_target(:app_extension, NAME, :ios, DEPLOYMENT)
group = project.main_group.find_subpath(NAME, true)
group.set_source_tree('<group>')
group.set_path(NAME)

%w[DueWidget.swift DueTokens.g.swift].each { |f| widget.add_file_references([group.new_file(f)]) }
group.new_file('Info.plist')
group.new_file('DueWidget.entitlements')

fonts = group.find_subpath('Fonts', true)
fonts.set_source_tree('SOURCE_ROOT')
FONTS.each do |f|
  ref = fonts.new_file("../../packages/due_kit/assets/fonts/#{f}.ttf")
  widget.resources_build_phase.add_file_reference(ref)
end

%w[WidgetKit SwiftUI].each do |fw|
  ref = project.frameworks_group.new_file("System/Library/Frameworks/#{fw}.framework", :sdk_root)
  widget.frameworks_build_phase.add_file_reference(ref)
end

widget.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{NAME}/Info.plist"
  s['CODE_SIGN_ENTITLEMENTS'] = "#{NAME}/#{NAME}.entitlements"
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = ''
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  # Flutter's per-configuration xcconfig supplies FLUTTER_BUILD_NAME/NUMBER.
  base = runner.build_configurations.find { |r| r.name == c.name }&.base_configuration_reference
  c.base_configuration_reference = base if base
end

runner.add_dependency(widget)
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' } ||
        runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.dst_subfolder_spec = '13' # PlugIns
build_file = embed.add_file_reference(widget.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Embed before Flutter's "Thin Binary" script, or Xcode reports a cycle.
phases = runner.build_phases
phases.delete(embed)
thin = phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } || phases.length
phases.insert(thin, embed)

project.save
puts "Added #{NAME} (#{BUNDLE_ID}) and embedded it in Runner."
