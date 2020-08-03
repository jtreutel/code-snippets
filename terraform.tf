#-------------------------------------------
#Count-based suffix numbers
#-------------------------------------------

#Three digit number based on current "count" number, starting with "1":
format("%03d", count.index + 1)


#-------------------------------------------
# Module Source
#-------------------------------------------

#Module in repo top level:
source = "git::ssh://git@example.com/somerepo.git"

#Module in repo subdir:
source = "git::ssh://git@example.com/somerepo.git//subdir"

#Module source using HTTPS and a specific ref:
source = "git::https://example.com/somerepo.git?ref=1.0.0"