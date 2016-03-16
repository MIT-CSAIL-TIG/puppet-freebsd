# Figure out where packages are installed (normally /usr/local but this
# is configurable).  Assume that the puppet package is installed in the
# same place as other packages.
Facter.add(:localbase ) do
  confine :osfamily => [ :FreeBSD ]  
  setcode do
    Facter::Util::Resolution.exec('pkg query "%p" puppet38')
  end
end
