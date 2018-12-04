# Git
DIR=/opt/git
mkdir -p $DIR/regvizQC

git clone https://github.com/kaitj/regvizQC $DIR/regvizQC
cd $DIR/regvizQC

# Install requirements
pip3 install -r requirements.txt

# Install regvizQC
python3 setup.py install
