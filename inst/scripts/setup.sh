
anno=$R_HOME/library/anno/scripts #for installed package
#anno=~/projects/anno/inst/scripts #for development

chmod 744 $anno/annoprep.r
chmod 744 $anno/annoimport.sh
chmod 744 $anno/annoprocess.sh
chmod 744 $anno/annocleanup.sh

#only make these links for the installed package, not for development!
#assumes ~/bin directory is in path
ln -s $anno/annoprep.r ~/bin/annoprep
ln -s $anno/annoimport.sh ~/bin/annoimport
ln -s $anno/annoprocess.sh ~/bin/annoprocess
ln -s $anno/annocleanup.sh ~/bin/annocleanup
