all: hello.exe

hello.exe: ..\osxdemo\hello.c
	$(CC) ..\osxdemo\hello.c
	signtool sign /f ..\codesign\signature-class.pfx /p changeit /fd SHA256 /t http://timestamp.digicert.com $@

clean:
	for %d in (*.exe *.obj) do if exist %d del %d

verify: hello.exe
	PowerShell /c Get-AuthenticodeSignature hello.exe
