pragma solidity ^0.4.15;

import "./Portfolio.sol";

contract PortfolioManager {
    address public exchanger;
    address public manager;
    mapping (address => address[]) public portfoliosOf;
    function PortfolioManager(address _exchanger, address _manager) public {
        manager = _manager;
        exchanger = _exchanger;
    }
    
    function createPortfolio(uint _algorythmId, address[] _currencies, 
        uint[] _algorythmParams) 
        public returns(address portfolioAddress) {
        Portfolio portfolio = new Portfolio(msg.sender, _algorythmId, _currencies, 
        _algorythmParams, exchanger, manager);
        // transferMoney(msg.sender, address(portfolio), _currencies);
        portfoliosOf[msg.sender].push(address(portfolio));
        
        return address(portfolio);
    }
    function getPortfoliosOf(address _user) public returns(address[] portfolios) {
        return portfoliosOf[_user];
    }
    function transferMoney(address _from, address _to, address[] _currencies) public {
        for (uint i = 0; i < _currencies.length; i++) {
            AbstractToken token = AbstractToken(_currencies[i]);
            uint allowedTokens = token.allowance(_from, _to);
            
            if (allowedTokens > 0) {
                assert(token.transferFrom(_from, _to, allowedTokens));
            }
        }
    }
}