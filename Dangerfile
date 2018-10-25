
# for debugging uncomment out these 2 lines
# require 'pry'
# binding.pry

# Run swiftlint
swiftlint.lint_files

# Localized Strings check
changedFiles = (git.added_files + git.modified_files).select{|file| file.end_with?(".swift")}
changedFiles.select{|file| file != "Blockzilla/UIConstants.swift" }.each do |changed_file|
  addedLines = git.diff_for_file(changed_file).patch.lines.select{ |line| line.start_with?("+") }
  if addedLines.select{ |line| line.include?("NSLocalizedString") }.count != 0
    warn("NSLocalizedString should only be added to Strings.swift")
    break # We only need to show the warning once
  end
end

# Add a friendly reminder for Sentry
changedFiles.each do |changed_file|
  addedLines = git.diff_for_file(changed_file).patch.lines.select{ |line| line.start_with?("+") }
  if addedLines.select{ |line| line.include?("Sentry.shared.send") }.count != 0 
    markdown("### Sentry check list")
    markdown("- [ ] I understand that only .fatal events will be reported on release")
    markdown("- [ ] The message param contains a string that will not create multiple events")
    break
  end
end

# Warn if diff contains !try or as!
changedFiles.each do |changed_file|
  # filter out only the lines that were added
  addedLines = git.diff_for_file(changed_file).patch.lines.select{ |line| line.start_with?("+") }
  warn("No new force try! or as!") if addedLines.select{ |line| (line.include?("as!") || line.include?("try!")) }.count != 0 
end

# TODO: Limit the number of new lines added to BVC to less than 10
