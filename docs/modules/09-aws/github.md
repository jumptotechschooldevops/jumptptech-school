---
title: "GitHub"
description: "At a high level, GitHub is a website and cloud-based service that helps developers store and manage..."
published: 2025-11-25
source: "https://dev.to/jumptotech/github-32c6"
tags: []
---

# GitHub

At a high level, GitHub is a website and cloud-based service that helps developers store and manage their code, as well as track and control changes to their code. To understand exactly what GitHub is, you need to know two connected principles:

Version control
Git

What Is Version Control?
Version control helps developers track and manage changes to a software project’s code. As a software project grows, version control becomes essential. Take WordPress…

At this point, WordPress is a pretty big project. If a core developer wanted to work on one specific part of the WordPress codebase, it wouldn’t be safe or efficient to have them directly edit the “official” source code.

Instead, version control lets developers safely work through branching and merging.

With branching, a developer duplicates part of the source code (called the repository). The developer can then safely make changes to that part of the code without affecting the rest of the project.

Then, once the developer gets his or her part of the code working properly, he or she can merge that code back into the main source code to make it official.



What Is Git?
Git is a specific open-source version control system created by Linus Torvalds in 2005.

Specifically, Git is a distributed version control system, which means that the entire codebase and history is available on every developer’s computer, which allows for easy branching and merging.







What Is GitHub?
GitHub is a for-profit company that offers a cloud-based Git repository hosting service. Essentially, it makes it a lot easier for individuals and teams to use Git for version control and collaboration.

GitHub’s interface is user-friendly enough so even novice coders can take advantage of Git. Without GitHub, using Git generally requires a bit more technical savvy and use of the command line.

GitHub is so user-friendly, though, that some people even use GitHub to manage other types of projects – like writing books.

Additionally, anyone can sign up and host a public code repository for free, which makes GitHub especially popular with open-source projects.

As a company, GitHub makes money by selling hosted private code repositories, as well as other business-focused plans that make it easier for organizations to manage team members and security. We utilize Github extensively at Kinsta to manage and develop internal projects.




Key Features of GitHub
Repositories: A repository (or repo) is where your project lives. It contains all your project's files and the history of all changes made to those files. You can create a new repository on GitHub to start a new project or to host an existing one.
Branching: Branches allow you to work on different versions of a project simultaneously. The main branch, often called "main" or "master," is the default branch. You can create new branches to develop features or fix bugs without affecting the main branch.
Pull Requests: A pull request (PR) is a way to propose changes to a repository. When you create a pull request, you are requesting that someone review and merge your changes into the main branch. Pull requests are essential for code reviews and collaborative development.
Issues: Issues are used to track tasks, enhancements, and bugs. You can assign issues to team members, add labels for categorization, and link issues to pull requests.
Actions: GitHub Actions allow you to automate your workflows. You can set up CI/CD (Continuous Integration and Continuous Deployment) pipelines to test and deploy your code automatically.
Getting Started with GitHub
Step 1:  Go to the Website
Go to the GitHub website and click the Sign-up button.






GitHub Dashboard
The Dashboard in GitHub is where you can see all the repositories you’ve created on the left-hand side. The updates from GitHub are made known to the developers on the right-hand side.

You can also view what your followers or those who you follow on GitHub are up to in the “For You” section or also get some trending news, similar to the “Trending” tab on YouTube.


The “Following” tab has a similar functionality to view what the people you follow on GitHub are up to. 


Since GitHub is a hosting platform, users can use repositories as a folder to upload files.

What is a GitHub Repository?
It has similar functionalities to a folder in a System to store various projects in different folders. As we know, GitHub is a web-hosting platform for developers, hence to properly segregate and store code, they provide the developers with the ability to store files of their projects in such repositories in which they can edit, add and delete files. If the repository is public, other platform users can notify the repository owner of any bugs by utilizing Pull requests. 

1. Create and Update Repositories on GitHub
The most important use case of GitHub is its ability as a hosting platform to store files on its website. GitHub provides developers with the tools to Create Repositories, update repositories either by editing files, or adding/deleting files. All these operations are seen in detail below. 

1.1. Using the ‘+’ button in GitHub to create a Repository
Log into your account on the GitHub webpage. Then click the “+” button. This will bring a drop-down box with some options. Click the “New Repository” button.


After clicking the button, it will redirect you to another page where you need to fill in the description and the necessary information for your repository.


It can be optional whether you want to choose your repository to be viewed publicly, that is, anyone accessing GitHub can view your repository and its contents, or it can be private, which means only you can see and access your GitHub repository.

You can type anything in the Description and tick the box next to “Add a README file” and create your repository. Once the repository is created, you can see the first file pushed (added) in your repository is the README file.

1.2. What is a README file?
A README.md file is used by developers to write a short description describing their project, or in the case of Open Source Software, they start to write a detailed description to install or use their software.

The ‘md’ in the README.md file stands for the Markdown file similar to markup languages such as HTML (HyperText Markup Language). It is used to style the README file for including code, or other things.

The concept of the README file is explained more in detail here.


The process to customize and create a repository is explained more in detail here. Once you've created your repository, you can start adding files according to your projects. Let's see how we add files to our repositories. 

2. How to Add Files to Your Repository?
Again, there are three ways to add files to your repository. One is using Git Bash, then with Github webpage UI and the other uses the Git GUI. In this article, we’ll learn to add files to your repository using the GitHub webpage. 






3. How to Delete a GitHub Repository?
To delete a repository, navigate to the settings bar in the repository you want to delete.


Scroll down to the end where you will come across the “Danger Zone” and will be provided a list of options. Click “Delete Repository”.


This will bring a popup where GitHub will ask you to type the name of the repository to confirm its deletion.


Once you know how to do all of these, it is important to learn about the labels available in your GitHub repository.

4. Labels in GitHub
They are a way to provide tags for descriptive metadata available in your repository. The main functionality of Labels in GitHub is to organize push/pull requests, issues, and the different types of items available in a repository. It is also possible to create your custom label in GitHub. 

The available labels and their description can be seen by navigating to the “Issues” section and clicking “Labels” to see all available labels.


The process to create a custom GitHub label in GitHub is explained in detail here.

5. Operations in GitHub
These are common procedures that have been performed on files in GitHub repositories with varying use cases. These are used to provide platform users with the ability to change the contents of their repositories dynamically.

Some of the common operations in GitHub are:

Creating pull and merge requests
Creating a branch
Cloning a repository
Forking a repository
5.1. Pull Request or Merge Request
In GitHub, users can create a Pull Request to let the owner know that some changes have been done to their files in the repository. It can only be accepted by the owner to implement changes in their code. 

Once the Pull Request is accepted, the merge request will be performed. This is to approve the process where the changed file will be merged into the repository, committing changes to the main branch.

.

git pull origin
git merge origin/master
6. What are Branches?
The branches in GitHub allow you to experiment safely with your code. Branches provide a safe space for code experimentation and debugging processes. Branches always start from the "main" repository and branch out to sub-repositories to test specific parts of the code in different environments. This is done to not commit any changes in the main code, but if needed the branches can be committed to the root repository. 

You can add or delete branches to a repository in GitHub and it is very easy to do so. To create a branch, we need a base repository to do so.

The operations that can be done are merge commands, push commands, and pull requests.

6.1. How to create a branch?
Go to your repository and click on the “main” branch. This will create a drop-down where you can choose a name for your branch and create it.


After creating it, it can be viewed when you select “View all Branches”.


6.2. How to Delete a Branch?
To delete a branch, simply click the trash icon in the branch to delete it.


7. Cloning Repositories
GitHub offers many features such as cloning repositories. This is done to keep a copy of the repository on your desktop, and the changes you make in the Desktop files will also be reflected on the GitHub page.

7.1 How to Clone a Repository?
For the above example to clone repositories, go to the GitHub repository you’d like to clone. Go to the repository you want to clone, and click the “Code” button.



8. Forking a Repository
A fork is created when a new repository is created by copying a previously existing public repository to add your changes to it. These changes can be personal or you could submit a pull request to the owner of the original repository to apply these changes. 

Forking repositories are done for a few reasons:
A. Starting Point For an Idea: To create your idea for a project, you can fork an existing repository as a code base and then expand on the idea from the base code.

B. Correct Any Mistakes Present in the Project: When you notice any glaring errors or bugs in a public repository, one of the ways to effectively do it to people you do not have contact info with is:

Fork the repository.
Edit the code to remove any bugs.
Submit a pull request to the owner to apply these changes.
Suppose you have created a repository for a project and uploaded it publicly. Another GitHub user who you may not know, may notice your profile and check it and may find some bugs. They can suggest some changes by forking your repository and applying the changes themselves then, submit a pull request to you. This is the difference between cloning and forking repositories.

8.1. How to fork a repository?
Go to the desired repository you’d like to fork and click the “Fork” button.

Fork GitHub Repository
This will redirect you to another page where you can customize the Repository name and the description.







