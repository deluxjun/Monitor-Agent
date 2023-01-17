set JAVA_HOME=C:\Java\jdk1.5.0_22_x86

@echo off
for /L %%n in (1,1,10) do start %JAVA_HOME%\bin\java.exe -DXmonConfig=xMonAgent%%n.xml -javaagent:lib/xmonitor_aspect_common.jar -DMonLogId=Log1 -cp .;lib/xmonitor_agent.jar xmonitor.AgentUnit
pause