#!/bin/bash


function usage()
{
    cat <<EOM
Usage: $0 [options] <url>
Options:
 -n, --name COMMAND    setting project_name
 -l, --lib  COMMAND    setting react|next
 -t, --typescript     setting typescript
EOM

    exit 1
}

lib="react"
function set_options()
{
    while [ "${1:-}" != "" ]; do
        case "$1" in
            -n | --name)
                shift
                project_name=$1
                ;;
            -l | --lib)
                shift
                lib=$1
                ;;
            -t | --typescript)
                ts="true"
                ;;
            *)
                usage
                ;;
        esac
        shift
    done
}

set_options "$@"

echo "project_name='${project_name}'"
echo "lib='${lib}'"
echo "ts='${ts}'"


if [ -z $project_name ]
then
  echo "Please set Project name.."
  echo "Usage option : -n | --name <project_name>"
  exit 0
fi


if [ $lib != react ] && [ $lib != next ]
then
  echo "Please choose between react or next"
  echo "Usage option : -l | --lib <react | next>"
  exit 0
fi


if [ $lib == react ]
then
  if [ $ts ]
  then
    yarn create react-app $project_name --template typescript
  else
    yarn create react-app $project_name
  fi
elif [ $lib == next ]
then
  if [ $ts ]
  then
    yarn create next-app $project_name --typescript
  else
    yarn create next-app $project_name
  fi
fi

echo "Delete node_modules and lock file..."
cd $project_name
rm -rf node_modules
rm -rf yarn.lock
rm -rf package-lock.json

echo "Set yarn berry..."
yarn set version berry

echo "Install packages..."
yarn

if [ $ts ]
then
  echo "Import typescript plugin..."
  yarn plugin import typescript
fi


echo "Set vscode sdk..."
yarn dlx @yarnpkg/sdks vscode

echo "Reinstall jest-dom..."
yarn remove @testing-library/jest-dom
yarn add -D @testing-library/jest-dom

read -p "Do you want to use zero-install? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\n.yarn/*\n!.yarn/cache\n!.yarn/patches\n!.yarn/plugins\n!.yarn/releases\n!.yarn/sdks\n!.yarn/versions" >> .gitignore
else
  echo -e "\n.pnp.*\n.yarn/*\n!.yarn/patches\n!.yarn/plugins\n!.yarn/releases\n!.yarn/sdks\n!.yarn/versions" >> .gitignore
fi

echo "Done."