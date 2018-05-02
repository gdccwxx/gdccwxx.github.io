#!/bin/bash
hexo g
hexo d
git add .
git commit -m "auto commit"
git push