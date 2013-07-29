@echo off

makesis qmltwitter.pkg qmltwitter_20034cc4.sis
signsis qmltwitter_20034cc4.sis qmltwitter_20034cc4.sis rd.cer rd-key.pem

makesis qmltwitter_20034cc4_installer.pkg qmltwitter_20034cc4_installer.sis
signsis qmltwitter_20034cc4_installer.sis qmltwitter_20034cc4_installer.sis rd.cer rd-key.pem

echo All steps finished...

