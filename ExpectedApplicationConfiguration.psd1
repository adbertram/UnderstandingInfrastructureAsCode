@{
	Name          = 'AppX'
	ServerTargets = @(
		@{
			Name               = 'WEBSRV1'
			ConfigurationItems = @(
				@{
					Type    = 'File'
					Path    = 'C:\SomeConfigFile.txt'
					Content = 'AppName=Foo, WebServiceName=WEBSRV1'
				}
			)
		}
		@{
			Name               = 'DC'
			ConfigurationItems = @(
				@{
					Type    = 'File'
					Path    = 'C:\SomeConfigFile.txt'
					Content = 'AppName=Foo, DBName=SQLSRV1'
				}
			)
		}
	)
}