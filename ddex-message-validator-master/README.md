# ddex-message-validator-api #
API for DDEX XML validator

# Todo #
- Detect ERN Version
- Detect Profile Version
- Verify Schemtron Coverage for 3.41
- Add additional ERN versions
- Figure out method signatures
- where does xslt go? resources?
- configuration file ... application.conf

# Assumptions

Business and Release Profiles are the same version

# Testing

curl -F "ernFile=@Profile_AudioAlbumMusicOnly.xml" localhost:8080/api/json/14/AudioAlbumMusicOnly
