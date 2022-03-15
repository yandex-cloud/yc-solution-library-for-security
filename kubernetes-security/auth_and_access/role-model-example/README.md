# Example of setting up role-based models and policies in Yandex Managed Service for Kubernetes®

# A detailed analysis in the video
[![image](https://user-images.githubusercontent.com/85429798/130356018-0840545a-da13-4faa-b15d-2858e3a9e369.png)](https://www.youtube.com/watch?v=ot6I_wmkLr4&t=1597s)


# A stand for a practice webinar on Kubernetes

The video from the stand will be available when published on YouTube.
The stand lets you to independently set up everything that was demonstrated at the webinar, for example:
- A role-based management model for different container environments.
- Pod launch policies in the created cluster.


## Prerequisites:

- Bash.
- Terraform.
- jq.
- [YC CLI](https://cloud.yandex.ru/docs/cli/operations/install-cli) initiated in the default profile for your user (they must be an admin or editor at the cloud level).
- Two test folders, you'll need their IDs below.
- Helm v3.

## Preparing the environment

The stand will include two folders and two users: devops and developer. 


Write down IDs of the folders for our task:

```
export STAGING_FOLDER_ID=<ID of the staging folder for the demo>
export PROD_FOLDER_ID=<ID of the prod folder for the demo>
```

Create service accounts that will emulate users:

```
$ yc iam service-account create --name devops-user1 --folder-id=$STAGING_FOLDER_ID
$ yc iam service-account create --name developer-user1 --folder-id=$STAGING_FOLDER_ID
```
Create two profiles for the CLI, one profile will emulate a devops user, the other one, a developer:
```
$ yc iam key create --service-account-name devops-user1 --folder-id=$STAGING_FOLDER_ID --output devops.json
$ yc iam key create --service-account-name developer-user1 --folder-id=$STAGING_FOLDER_ID --output developer.json

$ yc config profile create demo-devops-user1
$ yc config set service-account-key devops.json

$ yc config profile create demo-developer-user1
$ yc config set service-account-key developer.json
```
Check that no one has any roles in the folders for the task:
```
$ yc resource-manager folder list-access-bindings --id=$STAGING_FOLDER_ID --profile=default

+---------+--------------+------------+
| ROLE ID | SUBJECT TYPE | SUBJECT ID |
+---------+--------------+------------+
+---------+--------------+------------+

$ yc resource-manager folder list-access-bindings --id=$PROD_FOLDER_ID --profile=default

+---------+--------------+------------+
| ROLE ID | SUBJECT TYPE | SUBJECT ID |
+---------+--------------+------------+
+---------+--------------+------------+
```

Move on to the lab task.

#### Part one: Setting up role-based access 

```
$ cd ./terraform/iam
```

Look at the readme file [for this section](./terraform/iam/).

#### Part two: Setting up policies

(Part 1 is a prerequisite)

```
$ cd ./kubernetes/
```

Look at the readme [for this section](./kubernetes/).

#### Part three: delete the stand

```
$ cd ./end
```

Look at the readme [for this section](./end/).
