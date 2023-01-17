set JAVA_HOME=C:\Java\jdk1.5.0_22_x86

%JAVA_HOME%\bin\java.exe -DXmonConfig=xMonAgent_imsi.xml -javaagent:lib/xmonitor_aspect.jar -DMonLogId=Log1 -cp .;lib/xmonitor_agent.jar xmonitor.AgentUnit
pause