pragma solidity ^0.4.15;

import "./AbstractToken.sol";
import "./Exchanger.sol";

contract OurExchanger is Exchanger {
    address public manager;
    uint public constant BASE = 1000000000000000000;
    mapping (address => bool) public isTokenAllowed;
    mapping (address => mapping (address => uint)) public course;
    
    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }
    
    function OurExchanger(address _manager) public {
        manager = _manager;
    }
    function allowToken(address _token) public onlyManager {
        isTokenAllowed[_token] = true;
    }
    function rejectToken(address _token) public onlyManager {
        isTokenAllowed[_token] = false;
    }
    function setCourse(address _fromCurrency, address _toCurrency, uint _course) public onlyManager {
        course[_fromCurrency][_toCurrency] = _course;
    }
    function exchange(address _fromCurrency, address _toCurrency, uint _value) public {
        require(isTokenAllowed[_fromCurrency]);
        require(isTokenAllowed[_toCurrency]);
        assert(course[_fromCurrency][_toCurrency] > 0);
        AbstractToken fromToken = AbstractToken(_fromCurrency);
        AbstractToken toToken = AbstractToken(_toCurrency);
        
        assert(fromToken.allowance(msg.sender, address(this)) >= _value);
        
        uint toValue = _value * course[_fromCurrency][_toCurrency] / BASE;
        assert(toToken.balanceOf(address(this)) >= toValue);
        
        assert(fromToken.transferFrom(msg.sender, address(this), _value));
        assert(toToken.transfer(msg.sender, toValue));
    }
    function sendTokens(address _to, address _currency, uint _value) public onlyManager {
        AbstractToken token = AbstractToken(_currency);
        assert(token.balanceOf(address(this)) >= _value);
        assert(token.transfer(_to, _value));
    }
}