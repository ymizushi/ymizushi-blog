git add .
git commit -m "update content"
hugo
rsync -a public/ ../ymizushi.github.io/tech-memo/
cd ../ymizushi.github.io/tech-memo
git add .
git commit -m "update content"
git push origin master

