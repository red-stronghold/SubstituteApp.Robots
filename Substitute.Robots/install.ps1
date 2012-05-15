# First some common params, delivered by the nuget package installer
param($installPath, $toolsPath, $package, $project)

# Get the build project of type [Microsoft.Build.Evaluation.Project]
$buildProject = Get-Project $project.ProjectName | % {
            $path = $_.FullName
            @([Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($path))[0]
        }

# Get project path
$path = [System.IO.Path]
$projectpath = $path::GetDirectoryName($project.FileName)

# Get robots.txt
$robotstxt = $path::Combine($projectpath, "robots.txt")

# Create robots.txt if it doesnt exist
If (Test-Path $robotstxt)
{
    # robots.txt exists, no file creation needed.
}
Else
{
    # robots.txt does not exist, creating file.

	# create the new file
    new-item $robotstxt -type file

	# Add a new ItemGroup
	$itemGroup = $buildProject.Xml.AddItemGroup()

	# Add the Content node including "robots.txt" to the ItemGroup
	$itemGroup.AddItem("Content", "robots.txt")
}

# Find the Content node for "robots.txt.substitute.xml"
$robotssubstitute = $buildProject.Xml.ItemGroups | foreach {$_.Items} | Where-Object {$_.Include -match "robots.txt.substitute.xml"}

# Add a dependency to "robots.txt.txt" for "robots.txt.substitute.xml"
$robotssubstitute.AddMetaData("DependentUpon", "robots.txt.txt")

# Save the build project.
$buildProject.Save()

# Save the project from the params.
$project.Save()



