---
title: "Helm Kubernetes"
description: "The Purpose of Helm Helm is a tool for managing Kubernetes packages called charts. Helm can do the..."
published: 2025-11-26
source: "https://dev.to/jumptotech/helm-kubernetes-b55"
tags: []
---

# Helm Kubernetes







The Purpose of Helm
Helm is a tool for managing Kubernetes packages called charts. Helm can do the following:

Create new charts from scratch
Package charts into chart archive (tgz) files
Interact with chart repositories where charts are stored
Install and uninstall charts into an existing Kubernetes cluster
Manage the release cycle of charts that have been installed with Helm
For Helm, there are three important concepts:

The chart is a bundle of information necessary to create an instance of a Kubernetes application.
The config contains configuration information that can be merged into a packaged chart to create a releasable object.
A release is a running instance of a chart, combined with a specific config.


Components
Helm is an executable which is implemented into two distinct parts:

The Helm Client is a command-line client for end users. The client is responsible for the following:

Local chart development
Managing repositories
Managing releases
Interfacing with the Helm library
Sending charts to be installed
Requesting upgrading or uninstalling of existing releases
The Helm Library provides the logic for executing all Helm operations. It interfaces with the Kubernetes API server and provides the following capability:

Combining a chart and configuration to build a release
Installing charts into Kubernetes, and providing the subsequent release object
Upgrading and uninstalling charts by interacting with Kubernetes
The standalone Helm library encapsulates the Helm logic so that it can be leveraged by different clients.





How does Helm work?
Helm works by describing the application from definition to upgrade in what is known as a Helm chart. Helm uses charts (similar to a template) to pass resources to your Kubernetes cluster using the Kubernetes API. 

Helm uses a single command line interface (CLI) tool called helm to manage the Helm chart, along with a handful of simple commands that allow you to create, manage, and configure your application. 


What is a Helm chart?
Helm charts are a collection of files that describe a Kubernetes cluster’s resources and package them together as an application. They comprise three basic components: 

The chart - Chart.yaml defines the application metadata like name, version, dependencies, etc. 
Values - values.yaml sets values, which is how you will set variable substitutions for reusing your chart
You may also have a values JSON schema that describes a structure for the values file, which can help in creating dynamic forms and validating your values parameters.
The templates directory - templates/ houses your templates and combines them with the values set in your values.yaml file to create manifests
The charts directory - charts/ stores any chart dependencies you define in Chart.yaml and reconstruct with helm dependency build or helm dependency update.
Each time you install a Helm chart, you also create an instance of it, called a release. Helm charts are maintained with each new release, and you can easily use previous versions of the chart to roll back to your preferred configuration.

How to use Helm charts
After installing the Helm CLI, you have two options: use an existing chart with predefined resources and values or create a customized chart to package your own application resources.

Using a pre-existing chart
Using a pre-existing chart involves first adding the Helm repository to your Helm client, then setting specific configuration parameters in your values files at the time of install.

Your values files are the keys to reusing Helm charts for individual configurations. You can substitute any variable declared in values.yaml, and Helm will create the .values structure to hold these variables in the template. This makes the variables available to substitute in later configurations. You can pass as many values files to a chart as you want; Helm will combine them and render them together so it’s possible to reuse variable files.

Once you have committed or pushed your values configurations, you will be able to update, upgrade, and manage your application’s lifecycle through common helm commands.

Creating a customized chart
You may need to create a custom chart to package applications you want to reuse across your organization or within your specific workloads. This involves defining your application’s resources in the chart’s templates/ directory, setting configuration parameters through values files, and adding any metadata and documentation to the Chart.yaml file.

You can then package the chart using helm package and upload it to a public or private Helm repository, or distribute it directly.

Red Hat’s validated patterns are useful examples of existing Helm charts that you can also customize. Validated patterns are Helm charts that describe a full workload that has been deployed at a customer site and met a set of requirements for testing and maintenance. They can be used directly or modified to fit your own configuration’s needs.

Chart Management
helm create <name>                      # Creates a chart directory along with the common files and directories used in a chart.
helm package <chart-path>               # Packages a chart into a versioned chart archive file.
helm lint <chart>                       # Run tests to examine a chart and identify possible issues:
helm show all <chart>                   # Inspect a chart and list its contents:
helm show values <chart>                # Displays the contents of the values.yaml file
helm pull <chart>                       # Download/pull chart
helm pull <chart> --untar=true          # If set to true, will untar the chart after downloading it
helm pull <chart> --verify              # Verify the package before using it
helm pull <chart> --version <number>    # Default-latest is used, specify a version constraint for the chart version to use
helm dependency list <chart>            # Display a list of a chart’s dependencies:


Install and Uninstall Apps
helm install <name> <chart>                           # Install the chart with a name
helm install <name> <chart> --namespace <namespace>   # Install the chart in a specific namespace
helm install <name> <chart> --set key1=val1,key2=val2 # Set values on the command line (can specify multiple or separate values with commas)
helm install <name> <chart> --values <yaml-file/url>  # Install the chart with your specified values
helm install <name> <chart> --dry-run --debug         # Run a test installation to validate chart (p)
helm install <name> <chart> --verify                  # Verify the package before using it
helm install <name> <chart> --dependency-update       # update dependencies if they are missing before installing the chart
helm uninstall <name>                                 # Uninstalls a release from the current (default) namespace
helm uninstall <release-name> --namespace <namespace> # Uninstalls a release from the specified namespace


Perform App Upgrade and Rollback
helm upgrade <release> <chart>                            # Upgrade a release
helm upgrade <release> <chart> --rollback-on-failure      # If set, upgrade process rolls back changes made in case of failed upgrade.
helm upgrade <release> <chart> --dependency-update        # update dependencies if they are missing before installing the chart
helm upgrade <release> <chart> --version <version_number> # specify a version constraint for the chart version to use
helm upgrade <release> <chart> --values                   # specify values in a YAML file or a URL (can specify multiple)
helm upgrade <release> <chart> --set key1=val1,key2=val2  # Set values on the command line (can specify multiple or separate valuese)
helm upgrade <release> <chart> --force                    # Force resource updates through a replacement strategy
helm rollback <release> <revision>                        # Roll back a release to a specific revision
helm rollback <release> <revision>  --cleanup-on-fail     # Allow deletion of new resources created in this rollback when rollback fails


List, Add, Remove, and Update Repositories
helm repo add <repo-name> <url>   # Add a repository from the internet:
helm repo list                    # List added chart repositories
helm repo update                  # Update information of available charts locally from chart repositories
helm repo remove <repo_name>      # Remove one or more chart repositories
helm repo index <DIR>             # Read the current directory and generate an index file based on the charts found.
helm repo index <DIR> --merge     # Merge the generated index with an existing index file
helm search repo <keyword>        # Search repositories for a keyword in charts
helm search hub <keyword>         # Search for charts in the Artifact Hub or your own hub instance



Helm Release monitoring
helm list                       # Lists all of the releases for a specified namespace, uses current namespace context if namespace not specified
helm list --all                 # Show all releases without any filter applied, can use -a
helm list --all-namespaces      # List releases across all namespaces, we can use -A
helm list -l key1=value1,key2=value2 # Selector (label query) to filter on, supports '=', '==', and '!='
helm list --date                # Sort by release date
helm list --deployed            # Show deployed releases. If no other is specified, this will be automatically enabled
helm list --pending             # Show pending releases
helm list --failed              # Show failed releases
helm list --uninstalled         # Show uninstalled releases (if 'helm uninstall --keep-history' was used)
helm list --superseded          # Show superseded releases
helm list -o yaml               # Prints the output in the specified format. Allowed values: table, json, yaml (default table)
helm status <release>           # This command shows the status of a named release.
helm status <release> --revision <number>   # if set, display the status of the named release with revision
helm history <release>          # Historical revisions for a given release.
helm env                        # Env prints out all the environment information in use by Helm.


Download Release Information
helm get all <release>      # A human readable collection of information about the notes, hooks, supplied values, and generated manifest file of the given release.
helm get hooks <release>    # This command downloads hooks for a given release. Hooks are formatted in YAML and separated by the YAML '---\n' separator.
helm get manifest <release> # A manifest is a YAML-encoded representation of the Kubernetes resources that were generated from this release's chart(s). If a chart is dependent on other charts, those resources will also be included in the manifest.
helm get notes <release>    # Shows notes provided by the chart of a named release.
helm get values <release>   # Downloads a values file for a given release. use -o to format output


Plugin Management
helm plugin install <path/url>      # Install plugins
helm plugin list                    # View a list of all installed plugins
helm plugin update <plugin>         # Update plugins
helm plugin uninstall <plugin>      # Uninstall a plugin


https://helm.sh/docs/intro/cheatsheet/


