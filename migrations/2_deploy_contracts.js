var fs = require('fs');
eval(fs.readFileSync('../accounts-config.js')+'');
 
 var OurExchanger = artifacts.require("./OurExchanger.sol");
 var Portfolio = artifacts.require("./Portfolio.sol");
 var PortfolioManager = artifacts.require("./PortfolioManager.sol");
 var Token = artifacts.require("./Token.sol");
 
 module.exports = function (deployer) {
	var exchanger;
	var portfolioManager;
	var tokens = [];
	
	function deployTokens() {
		var nextThen = Token.new(user).then(t => { tokens.push(t) });
		
		for (var i = 0; i < 4; i++) {
			nextThen = nextThen.then( () => Token.new(user) ).then( t => { tokens.push(t) } );
		}
		
		return nextThen;
	}
	
	deployer.deploy(OurExchanger, ourAdministrator)
		.then( () => OurExchanger.deployed() )
		.then(function (_exchanger) {
			exchanger = _exchanger;
			return deployer.deploy(PortfolioManager, exchanger.address, ourAdministrator);
		})
		.then( deployTokens )
		.then( () => PortfolioManager.deployed() )
		.then( (_portfolioManager) => {
			portfolioManager = _portfolioManager;
			
			var configObject = {
				exchangerAddr : exchanger.address,
				portfolioManagerAddr: portfolioManager.address,
				portfolioManagerAbi: portfolioManager.abi,
				tokenAddrs: tokens.map(t => t.address),
                tokenAbi: Token.abi,
				accounts: accounts,
				user: user,
			};
			
			fs.writeFileSync('./web/config.js', 'const CONFIG = ' + JSON.stringify(configObject) + ';');
		} );
}