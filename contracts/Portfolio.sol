pragma solidity ^0.4.15;

import "./Exchanger.sol";
import "./AbstractToken.sol";

contract Portfolio {
    address public owner;
    address public manager;
    uint public algorythmId;
    address[] public currencies;
    uint[] public algorythmParams;
    bool public isClosed = false;
    Exchanger public exchanger;
    
    modifier onlyOpened {
        require(!isClosed);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }
    
    function Portfolio(address _owner, uint _algorythmId, address[] _currencies, 
        uint[] _algorythmParams, address _exchanger, address _manager) public {
        require(_owner != 0x0);
        
        algorythmId = _algorythmId;
        currencies = _currencies;
        algorythmParams = _algorythmParams;
        exchanger = Exchanger(_exchanger);
        manager = _manager;
    }
    function addCurrency(address _currency) public onlyManager {
        AbstractToken token = AbstractToken(_currency);
        
        uint allowedTokens = token.allowance(owner, address(this));
        if (allowedTokens > 0) {
            assert(token.transferFrom(owner, address(this), allowedTokens));
        }
        
        currencies.push(_currency);
    }
	function getCurrencyIndex(address _forSearch) private returns(uint index) {
        for (uint curCurrencyIndex = 0; curCurrencyIndex < currencies.length; curCurrencyIndex++) {
            if (currencies[curCurrencyIndex] == _forSearch) {
                return curCurrencyIndex;
            }
        }
		// The currency is not found
		assert(false);
	}
    function removeCurrency(address _currency) public onlyManager {
        assert(currencies.length > 0);
        
        uint curCurrencyIndex = getCurrencyIndex(_currency);
        if (curCurrencyIndex < currencies.length - 1) {
            currencies[curCurrencyIndex] = currencies[currencies.length - 1];
        }
        delete currencies[currencies.length - 1];
        currencies.length--;
        
        returnCurrency(_currency);
    }
    function changeAlgorythmParams(uint _algorythmId, uint[] _algorythmParams) public onlyOwner {
        algorythmId = _algorythmId;
        algorythmParams = _algorythmParams;
    }
    function returnCurrency(address _currency) public {
        assert(msg.sender == owner || msg.sender == address(this));
        
        AbstractToken token = AbstractToken(_currency);
        uint tokenBalance = token.balanceOf(owner);
        if (tokenBalance > 0) {
            assert(token.transfer(owner, tokenBalance));
        }
    }
    function close() public onlyOwner {
        for (uint i = 0; i < currencies.length; i++) {
            returnCurrency(currencies[i]);
        }
        isClosed = true;
    }
    function exchange(address _fromCurrency, address _toCurrency, uint _value) public onlyOpened onlyManager {
        // TODO: add check for currency allowance
        AbstractToken fromToken = AbstractToken(_fromCurrency);
        
        assert(fromToken.balanceOf(address(this)) >= _value);
        assert(fromToken.approve(address(exchanger), _value));
        
        exchanger.exchange(_fromCurrency, _toCurrency, _value);
    }
}