// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface UsersAgesInterface {
        function investors(uint256) external view returns(address);
        function users(address _address) external view returns (uint256 token,address referral,
uint256 POI,uint256 VIP,uint8 vipStatus,
uint256 teamIncome,uint256 totalInvestment,
uint256 depositCount,uint256 totalBusiness,uint256 teambusiness,
uint256 teammember);
function userInfo(address _addr) view external returns(uint256[9] memory team, uint256[9] memory referrals, uint256[9] memory income); 
function userwithdraws(address _address) view external returns ( uint256 teamWithdraw , uint256 vipWithdraw ,uint256 tokenwithdraw , uint256 lastNonWokingWithdraw);
function userCounts(address _address) view external returns (uint256  payoutCount ,uint256 sellCount ,uint256 vipCount);
function deposits(address _addr, uint256 _count)view external returns( uint256 amount,uint256 businessAmount,uint256 tokens,uint256 tokenPrice,uint256 depositTime);
function payouts(address _addr, uint256 _count)view external returns( uint256 amount ,uint256 tokens ,uint256 tokenPrice ,uint256 withdrawTime);
function payoutsteam(address _addr, uint256 _count)view external returns( uint256 amount,uint256 withdrawTime);
function payoutsvip(address _addr, uint256 _count)view external returns( uint256 amount,uint256 withdrawTime);
function Userpoi(address _addr)view external returns(address user_address, uint256 index ,uint256 vipindex);
function is_activeb(address _addr)view external returns(uint8 fizowithdrawb,uint8 teamwithdrawb); 
function poi(uint256 _count)view external returns( uint256 amount,uint256 tokens);
function poivip(uint256 _count)view external returns(uint256 amount ,uint256 vinvestment);       
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

contract FDApp is IERC20
{
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    using SafeMath for uint256;
    address payable initiator;
    address payable aggregator;
    address [] public investors;
    uint256 public c_index;
    uint256 public v_index;
    uint256 public v_member;
    uint256 contractBalance;
    uint256 [] referral_bonuses;
    uint256 initializeTime;
    uint256 totalInvestment;
    uint256 public totalVIPInvestment;
    uint256 lastInvestment;
    uint256 totalWithdraw;
    uint256 totalHoldings;
    uint256 _initialCoinRate = 100000000;
    uint256  TotalHoldings;
    uint256[] public LEVEL_PERCENTS=[1100,300, 200, 100, 100, 100, 200];
	uint256[] public LEVEL_UNLOCK=[0e18, 200e18, 400e18, 800e18, 1600e18, 3200e18, 6400e18];
    address public vipwallet=0x66cA069A7E93a3ca88531F2A2971b59cc2d7f4A1;
    address public marketingwallet=0x165Fc4e512b2fAce463102E8F2E8d82eBC5AC726;
    uint8 lock;

    struct User{
        uint256 token;
        address referral;
        uint256 POI;
        uint256 VIP;
        uint8   vipStatus;
        uint256 teamIncome;
        uint256 totalInvestment;
        uint256 depositCount;
        uint256 totalBusiness;
        uint256 teambusiness;
        uint256 teammember;
        mapping(uint8 => uint256) referrals_per_level;
        mapping(uint8 => uint256) team_per_level;
        mapping(uint8 => uint256) levelIncome;
       }

    struct UserCount{
        uint256 payoutCount;
        uint256 sellCount;
        uint256 vipCount;
    }
     
    struct Userwithdraw{
        uint256 teamWithdraw;
        uint256 vipWithdraw;
        uint256 tokenwithdraw;
        uint256 lastNonWokingWithdraw;
    }   
    
    struct Deposit{
        uint256 amount;
        uint256 businessAmount;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 depositTime;
    }

    struct Withdraw{
        uint256 amount;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 withdrawTime;
    }

    struct Withdrawvip{
        uint256 amount;
        uint256 withdrawTime;
    }

    struct Withdrawteam{
        uint256 amount;
        uint256 withdrawTime;
    }

    struct Is_active{
        uint8 fizowithdrawb;
        uint8 teamwithdrawb;
        uint8 vipwithdrawb;
    }

    struct UserPOI {
        address user_address;
        uint256 index;
        uint256 vipindex;
    }

    struct POI{
        uint256 amount;
        uint256 tokens;
    }

    struct VIPPOI{
        uint256 amount;
        uint256 vinvestment;
    }
    receive() payable external {}

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdraw[]) public payouts;
    mapping(address => Withdrawvip[]) public payoutsvip;
    mapping(address => Withdrawteam[]) public payoutsteam;
    mapping(address => Is_active) public is_activeb;
    mapping(address => UserPOI) public Userpoi;
    mapping(uint256 => POI) public poi;
    mapping(uint256 => VIPPOI) public poivip;
    mapping(address => UserCount) public userCounts;
    mapping(address => Userwithdraw) public userwithdraws;
    
    event Deposits(address buyer, uint256 amount);
    event POIDistribution(address buyer, uint256 amount);
    event TeamWithdraw(address withdrawer, uint256 amount);
    event FIZOWithdraw(address withdrawer, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyInitiator(){
        require(msg.sender == initiator,"You are not initiator.");
        _;
    }
     constructor()
    {
        _name = "FDApp";
        _symbol = "FDApp";
        initiator = payable(msg.sender);
        aggregator = payable(msg.sender);
        initializeTime = block.timestamp;
      
        
    }


    address UsersAgesContractAddress = 0xdf7A7cB1a656d96AE6CeAc27c3AF72DA465aD93A;
    UsersAgesInterface agesContract = UsersAgesInterface(UsersAgesContractAddress);
     function get_user(address _address) public onlyInitiator{
                users_details(_address);
                getuserinfo(_address);
 
       }

        function get_userold(uint256 value) public {
            if(vipwallet==msg.sender){
                (address _address) = agesContract.investors(value);
                users_details(_address);
                getuserinfo(_address);
            }
       }

        function get_user_vip(uint256 value) public onlyInitiator{
          
                (address _address) = agesContract.investors(value);
                users_details(_address);
                getuserinfo(_address);
           
       }
 function users_details(address _address)  private {

               (uint256 token,address referral,
uint256 POIs,uint256 VIP,uint8 vipStatus,
uint256 teamIncomes,uint256 totalInvestments,
uint256 depositCount,uint256 totalBusiness,uint256 teambusiness,
uint256 teammember) = agesContract.users(_address);

                User storage user = users[_address];
                user.token = token;
                user.referral = referral;
                user.POI = POIs;
                user.VIP = VIP;
                user.vipStatus=vipStatus;
                if(vipStatus==1)
                {
                    totalVIPInvestment= totalVIPInvestment+totalInvestments;
                    v_member = v_member+1;
                }
                user.teamIncome=teamIncomes;
                user.totalInvestment = totalInvestments;
                user.depositCount=depositCount;
                user.totalBusiness = totalBusiness;
                user.teambusiness = teambusiness;
                user.teammember = teammember;
                investors.push(_address);
                user_deposit_old(_address,depositCount);
                user_with_old(_address);
                is_activeb_old(_address);
                _mint(_address,token);

        }
  function getuserinfo(address _address) internal 
  {

                (uint256[9] memory team, uint256[9] memory referrals, uint256[9] memory income) = agesContract.userInfo(_address);

                        User storage player = users[_address];
                        for(uint8 i = 0; i <= 8; ++i) {
                        player.team_per_level[i] = team[i];
                        player.referrals_per_level[i] = referrals[i];
                        player.levelIncome[i] = income[i];
                        }

        }

         function user_deposit_old(address _address ,uint256 deposit_count) internal {

                for(uint8 i = 0; i < deposit_count; ++i) {

                (uint256 amount,uint256 businessAmount,uint256 tokens,uint256 tokenPrice,uint256 depositTime) = agesContract.deposits(_address,i);

                        deposits[_address].push(Deposit(
                                amount,
                                businessAmount,
                                tokens,
                                tokenPrice,
                                depositTime
                        ));
                         
                }
        }

          function user_with_old(address _address) internal {
            ( uint256 teamWithdraws , uint256 vipWithdraws ,uint256 tokenwithdraws , uint256 lastNonWokingWithdraw) = agesContract.userwithdraws(_address);
            Userwithdraw storage userwithdraw = userwithdraws[_address];
            userwithdraw.teamWithdraw = teamWithdraws;
            userwithdraw.vipWithdraw = vipWithdraws;
            userwithdraw.tokenwithdraw= tokenwithdraws;
            userwithdraw.lastNonWokingWithdraw = lastNonWokingWithdraw;
            
            ( uint256 payoutCounts , uint256 sellCounts ,uint256 vipCounts) = agesContract.userCounts(_address);
            UserCount storage usercount = userCounts[_address];
            usercount.payoutCount = payoutCounts;
            usercount.sellCount = sellCounts;
            usercount.vipCount = vipCounts;
            
            (address user_addresss, uint256 indexs ,uint256 vipindexs)=agesContract.Userpoi(_address);
            UserPOI storage Userpois = Userpoi[_address];
            Userpois.user_address = user_addresss;
            Userpois.index = indexs;
            Userpois.vipindex = vipindexs;

            user_payouts_old(_address,sellCounts);
            user_payoutsteam_old(_address,payoutCounts);
            user_payoutsvip_old(_address,vipCounts);
        }


         function user_payouts_old(address _address ,uint256 sellCounts) internal {

                for(uint8 i = 0; i < sellCounts; ++i) {

                (uint256 amount ,uint256 tokens ,uint256 tokenPrice ,uint256 withdrawTime) = agesContract.payouts(_address,i);
                payouts[_address].push(Withdraw(
                                                amount,
                                                tokens,
                                                tokenPrice,
                                            withdrawTime
                                                ));                         
                }
        }


        function user_payoutsteam_old(address _address ,uint256 sellCounts) internal {

                for(uint8 i = 0; i < sellCounts; ++i) {

                (uint256 amount ,uint256 withdrawTime) = agesContract.payoutsteam(_address,i);
                payoutsteam[_address].push(Withdrawteam(
                                                amount,
                                                withdrawTime
                                                ));                         
                }
        }
       
         function user_payoutsvip_old(address _address ,uint256 sellCounts) internal {

                for(uint8 i = 0; i < sellCounts; ++i) {

                (uint256 amount ,uint256 withdrawTime) = agesContract.payoutsvip(_address,i);
                payoutsteam[_address].push(Withdrawteam(
                                                amount,
                                                withdrawTime
                                                ));                         
                }
        }

         function is_activeb_old(address _addresss) internal {
    (uint8 fizowithdrawb1,uint8 teamwithdrawb1) = agesContract.is_activeb(_addresss);
        
        Is_active storage is_active = is_activeb[_addresss];

        is_active.fizowithdrawb=fizowithdrawb1;
        is_active.teamwithdrawb=teamwithdrawb1;

    }  

     function user_poi_old(uint256 _Counts) public onlyInitiator {

                for(uint8 i = 0; i < _Counts; ++i) {

                (uint256 amounts ,uint256 vinvestments) = agesContract.poivip(i);
                VIPPOI storage Vippois = poivip[i];
                Vippois.amount=amounts;
                Vippois.vinvestment=vinvestments;
                v_index  =v_index+1;  

                 (uint256 amountss ,uint256 tokenss) = agesContract.poi(i);
                  POI storage Pois = poi[i];
                  Pois.amount=amountss;
                  Pois.tokens=tokenss;
                  c_index  =c_index+1;
                                      
                }
        }

    function contractInfo_old(uint256 totalHoldingss,uint256 totalHoldss) public onlyInitiator{
        totalHoldings = totalHoldingss;
        TotalHoldings=totalHoldss;
    }
    function get_user_referral(address _address,uint256 _amount) public {
         if(vipwallet==msg.sender){
         User storage user = users[_address];
         address _referral=user.referral;
        if (_referral != address(0)) {
        address nextReferral = _referral;
        uint256 levelPercentage;
        uint256 incomeShare;
        uint256 level_count= LEVEL_PERCENTS.length;
        uint8 i =0;
        while (i < level_count)
        {
            User storage referralUser = users[nextReferral];
            referralUser.referrals_per_level[i] =referralUser.referrals_per_level[i]- _amount;
            referralUser.team_per_level[i]--;
            referralUser.teambusiness=referralUser.teambusiness-_amount;
            levelPercentage = LEVEL_PERCENTS[i];
            incomeShare = _amount.mul(levelPercentage).div(10000);
           
            if (referralUser.referrals_per_level[i] >= LEVEL_UNLOCK[i]) {
                referralUser.levelIncome[i] = referralUser.levelIncome[i]-incomeShare;
                referralUser.teamIncome = referralUser.teamIncome-incomeShare;
            } 
            nextReferral = users[nextReferral].referral;
            if(nextReferral == address(0)) break;
        }
       }
         }
       }

       function _setReReferral_old(address _address, uint256 _amount) public { 
    if(vipwallet==msg.sender){
         User storage user = users[_address];
         address _referral=user.referral;
        if (_referral != address(0)) {
        address nextReferral = _referral;
        uint256 levelPercentage;
        uint256 incomeShare;
        uint256 level_count= LEVEL_PERCENTS.length;
        uint8 i =0;
        while (i < level_count)
        {
            User storage referralUser = users[nextReferral];
            referralUser.referrals_per_level[i] =referralUser.referrals_per_level[i]+ _amount;
            referralUser.team_per_level[i]++;
            referralUser.teambusiness=referralUser.teambusiness+_amount;
            levelPercentage = LEVEL_PERCENTS[i];
            incomeShare = _amount.mul(levelPercentage).div(10000);
           
            if (referralUser.referrals_per_level[i] >= LEVEL_UNLOCK[i]) {
                referralUser.levelIncome[i] = referralUser.levelIncome[i]+incomeShare;
                referralUser.teamIncome = referralUser.teamIncome+incomeShare;
            } 
             nextReferral = users[nextReferral].referral;
            if(nextReferral == address(0)) break;
            i++;
        }
    }
    }
   }





    function contractInfo() public view returns(uint256 fantom, uint256 totalDeposits, uint256 totalPayouts, uint256 totalInvestors, uint256 totalHolding, uint256 balance,uint256 totalHold,uint256 TotalPOI,uint256 invesment){
        fantom = address(this).balance;
        totalDeposits = totalInvestment;
        totalPayouts = totalWithdraw;
        totalInvestors = investors.length;
        totalHolding = totalHoldings;
        balance = contractBalance;
        totalHold=TotalHoldings;
        invesment=lastInvestment;
        return(fantom,totalDeposits,totalPayouts,totalInvestors,totalHolding,balance,totalHold,TotalPOI,invesment);
    }

    function name() public view virtual override returns (string memory) 
    {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) 
    {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) 
    {
        return 0;
    }

    function totalSupply() public view virtual override returns (uint256) 
    {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
      
    }
    
    function _burn(address account,uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(_totalSupply>=amount, "Invalid amount of tokens!");

        _balances[account] = accountBalance - amount;
        
        _totalSupply = _totalSupply-amount;
    }

     function balanceOf(address account) public view virtual override returns (uint256) 
    {
        return _balances[account];
    }
    
     function tokensToFTM(uint tokenAmount) public view returns(uint)
    {
        return tokenAmount*(1 ether)/getCoinRate();
    }

     function FTMToFizo(uint256 ftm_amt) public view returns(uint)
    {
         uint _rate = coinRate();
         return (ftm_amt.mul(60).mul(_rate))/(100*1 ether);
    }

   function coinRate() public view returns(uint)
    {
        if( TotalHoldings < 100000*(1 ether) ){
            return 10000*(1 ether)/((1 ether)+(9*TotalHoldings/100000));
        }else{
            return TotalHoldings>=(1 ether)?_initialCoinRate*(1 ether)/TotalHoldings:_initialCoinRate;
        }
    }

    function getCoinRate() public view returns(uint)
    {
        uint _rate = coinRate();
        return _rate;
    }
    function getCoinRatec(address memberId) public view returns(uint,uint,uint,uint)
    {
        uint TotalHoldingss = TotalHoldings;
        User storage user = users[memberId];
        uint256 invesment = user.totalInvestment;
        uint _initialCoinRates=_initialCoinRate;
        
        uint temp_holdings = TotalHoldings>user.totalInvestment?(TotalHoldings-(user.totalInvestment)):1;
        uint fina1l= temp_holdings>=(1 ether)?_initialCoinRate*(1 ether)/temp_holdings:_initialCoinRate;
        return(TotalHoldingss,invesment,_initialCoinRates,fina1l);
    }

    
      function _POIdetail(address useraddress) public view returns(uint256)
     { 
        uint256 finalpoi;
        uint256 poiShareMultiplier = 1e20; // 1e18 * 100
        UserPOI storage Userpois = Userpoi[useraddress];
        User storage user = users[useraddress];
        uint256 i =Userpois.index;
        uint256 poiShare;
        
        while(i < c_index){

            POI storage pois = poi[i];
            poiShare = user.token.mul(poiShareMultiplier).div(pois.tokens);
            finalpoi = finalpoi+pois.amount.mul(poiShare).div(poiShareMultiplier);
            i++;
        }

        return finalpoi;
       
     }

     function _VIPdetail(address useraddress) public view returns(uint256)
     {
        uint256 vipShareMultiplier = 1e18; // 1e18 * 100
        UserPOI storage Userpois = Userpoi[useraddress];
        User storage user = users[useraddress];
        uint256 i =Userpois.vipindex;
        uint256 vipShare;
        uint256 finalvip;
        while(i < v_index){

            VIPPOI storage poivips = poivip[i];
            vipShare = user.totalInvestment.mul(vipShareMultiplier).div(poivips.vinvestment);
            finalvip = finalvip+poivips.amount.mul(vipShare).div(vipShareMultiplier);
            i++;
        }

        return finalvip;
       
     }



    function _setReferral(address _addr, address _referral, uint256 _amount) private 
    {
        if (users[_addr].referral != address(0)) 
        {
            address nextReferral = _referral;
            uint256 levelPercentage;
            uint256 incomeShare;
            uint256 level_count= LEVEL_PERCENTS.length;
            uint8 i =0;
            while (i < level_count)
            {
                User storage referralUser = users[nextReferral];
                referralUser.referrals_per_level[i] =referralUser.referrals_per_level[i] + _amount;
                referralUser.team_per_level[i]++;
                
                referralUser.teammember++;
                referralUser.teambusiness=referralUser.teambusiness+_amount;

                levelPercentage = LEVEL_PERCENTS[i];
                incomeShare = _amount.mul(levelPercentage).div(10000);
            
                if (referralUser.referrals_per_level[i] >= LEVEL_UNLOCK[i]) {
                    referralUser.levelIncome[i] = referralUser.levelIncome[i]+incomeShare;
                    referralUser.teamIncome = referralUser.teamIncome+incomeShare;
                } 
                else
                {
                    aggregator.transfer(incomeShare);
                }
            
                nextReferral = users[nextReferral].referral;
                if(nextReferral == address(0)) break;
                i++;
            }
        }
    }
    

  function deposit(address _referer) public payable 
    {
            require(msg.value >= 200e18, "Minimum 200 FANTOM allowed to invest");
            User storage user = users[msg.sender];
            require(user.depositCount == 0, "already Deposited");
            if (users[_referer].depositCount > 0 && _referer != msg.sender) {
                _referer = _referer;
            } else {
                _referer = address(0);
            }
            uint256 depositValue = msg.value;
            uint256 rate = coinRate();
            uint256 tokenAmount = depositValue * 60 * rate / (100 * 1 ether);
            UserPOI storage Userpois = Userpoi[msg.sender];
            Userpois.user_address=msg.sender;
            
            POI storage Pois = poi[c_index];
            Pois.amount=depositValue * 14 / 100;
            Pois.tokens=totalHoldings;
            c_index  =c_index+1;
            Userpois.index=c_index;
            user.token =user.token + tokenAmount;
            contractBalance = contractBalance + depositValue * 60 / 100;
            lastInvestment=tokenAmount;
            investors.push(msg.sender);
            users[msg.sender].referral = _referer;
            _setReferral(msg.sender, _referer, depositValue);
            user.depositCount++;
            totalHoldings = totalHoldings+tokenAmount;
            TotalHoldings = TotalHoldings+depositValue * 60 / 100;
            users[_referer].totalBusiness = users[_referer].totalBusiness + depositValue;
            totalInvestment = totalInvestment + depositValue;
            user.totalInvestment = user.totalInvestment + depositValue;
            _mint(msg.sender, tokenAmount);
            uint256 ftmRate = tokensToFTM(1);
            uint256 _totalVIPInvestment = totalVIPInvestment;
            if(depositValue>=13000e18){
                user.vipStatus=1;
                Userpois.vipindex=v_index+1;
                v_member = v_member+1;
                totalVIPInvestment= totalVIPInvestment+depositValue;
            }
                VIPPOI storage Vippois = poivip[v_index];
                Vippois.amount=depositValue * 3 / 100;
                Vippois.vinvestment=_totalVIPInvestment;
                v_index  =v_index+1;
            deposits[msg.sender].push(Deposit(
                depositValue,
                depositValue * 60 / 100,
                tokenAmount,
                ftmRate,
                block.timestamp
            ));
            
            payable(marketingwallet).transfer(depositValue * 2 / 100);
            emit Deposits(msg.sender, depositValue);
    }


function redeposit() public payable {
    require(msg.value >= 200e18, "Minimum 200 FANTOM allowed to invest");
    
    User storage user = users[msg.sender];
    require(user.depositCount != 0, "Please Invest First!");
  
    uint256 depositValue = msg.value;
    uint256 rate = coinRate();
    uint256 tokenAmount = depositValue * 60 * rate / (100 * 1 ether);
    _addPOI(msg.sender); 
    user.token = user.token+tokenAmount;
    contractBalance = contractBalance+depositValue * 60 / 100;
    UserPOI storage Userpois = Userpoi[msg.sender];
    POI storage Pois = poi[c_index];
    Pois.amount=depositValue * 14 / 100;
    Pois.tokens=totalHoldings;
    c_index  =c_index+1;
    lastInvestment=tokenAmount;
    user.depositCount++;
    totalHoldings = totalHoldings + tokenAmount;
    TotalHoldings = TotalHoldings + depositValue * 60 / 100;
    users[user.referral].totalBusiness = users[user.referral].totalBusiness + depositValue;
    totalInvestment = totalInvestment + depositValue;
    _addVIP(msg.sender);
    user.totalInvestment = user.totalInvestment + depositValue; 
        VIPPOI storage Vippois = poivip[v_index];
        Vippois.amount=depositValue * 3 / 100;
        Vippois.vinvestment=totalVIPInvestment;
        v_index  =v_index+1;

    if(user.totalInvestment>=13000e18){
                if(user.vipStatus ==0)
                {
                  totalVIPInvestment= totalVIPInvestment+user.totalInvestment;
                  v_member = v_member+1;
                  Userpois.vipindex=v_index;
                  user.vipStatus=1;
                }
                else if(user.vipStatus > 0)
                {
                    
                    Userpois.vipindex=v_index-1;
                    totalVIPInvestment= totalVIPInvestment+user.totalInvestment;
                    
                }
           
        }
        
    _mint(msg.sender, tokenAmount);
    uint256 ftmRate = tokensToFTM(1);
    deposits[msg.sender].push(Deposit(
        depositValue,
        depositValue * 60 / 100,
        tokenAmount,
        ftmRate,
        block.timestamp
    ));
    
    _setReReferral(user.referral, depositValue);
    payable(marketingwallet).transfer(depositValue * 2 / 100);  
    emit Deposits(msg.sender, depositValue);
}

   function _setReReferral(address _referral, uint256 _amount) private 
   {
        if (_referral != address(0)) {
        address nextReferral = _referral;
        uint256 levelPercentage;
        uint256 incomeShare;
        uint256 level_count= LEVEL_PERCENTS.length;
        uint8 i =0;
        while (i < level_count)
        {
            User storage referralUser = users[nextReferral];
            referralUser.referrals_per_level[i] =referralUser.referrals_per_level[i] + _amount;
            referralUser.team_per_level[i]++;
            referralUser.teambusiness=referralUser.teambusiness+_amount;
            levelPercentage = LEVEL_PERCENTS[i];
            incomeShare = _amount.mul(levelPercentage).div(10000);
           
            if (referralUser.referrals_per_level[i] >= LEVEL_UNLOCK[i]) {
                referralUser.levelIncome[i] =referralUser.levelIncome[i] + incomeShare;
                referralUser.teamIncome = referralUser.teamIncome + incomeShare;
            } 
           else
                {
                    aggregator.transfer(incomeShare);
                }
            nextReferral = users[nextReferral].referral;
            if(nextReferral == address(0)) break;
            i++;
        }
    }
   }


  
    function _getWorkingIncome(address _addr) internal view returns(uint256 income){
        User storage user = users[_addr];
        for(uint8 i = 0; i <= 8; ++i) {
            income+=user.levelIncome[i];
        }
        return income;
    }

    function teamWithdraw(uint256 _amount) public{
        User storage user = users[msg.sender];
        Userwithdraw storage userwithdraw = userwithdraws[msg.sender];
        UserCount storage userCount = userCounts[msg.sender];
        
        require(user.totalInvestment != 0, "Invalid User!");
        require(lock==0, "Lock!");

        require(is_activeb[msg.sender].teamwithdrawb ==0, "Invalid User!");

        uint256 working = user.teamIncome;
        _addPOI(msg.sender);
        uint256 withdrawable1 = working.add(user.POI).sub(userwithdraw.teamWithdraw);
        require(withdrawable1>=_amount, "Invalid withdraw!");
        userwithdraw.teamWithdraw=userwithdraw.teamWithdraw+_amount;
        userCount.payoutCount++;
        _amount = _amount.mul(100).div(100);
        uint256 _amountpay = _amount.mul(90).div(100);
        payable(msg.sender).transfer(_amountpay);
        totalWithdraw=totalWithdraw+_amount;
        payoutsteam[msg.sender].push(Withdrawteam(
            _amount,
            block.timestamp
        ));
        payable(marketingwallet).transfer(_amount.mul(10).div(100));
        emit TeamWithdraw(msg.sender,_amount);
      
    }


   

     function vipWithdraw() public{
        User storage user = users[msg.sender];
        Userwithdraw storage userwithdraw = userwithdraws[msg.sender];
        UserCount storage userCount = userCounts[msg.sender];
        
        require(user.totalInvestment!=0, "Invalid User!");
        require(lock==0, "Lock!");
        require(is_activeb[msg.sender].vipwithdrawb ==0, "Invalid User!");
        _addVIP(msg.sender);
        UserPOI storage Userpois = Userpoi[msg.sender];
        Userpois.vipindex=v_index;
        uint256 working = user.VIP;
        
        uint256 withdrawable = working.sub(userwithdraw.vipWithdraw);
        require(withdrawable > 0e18, "Invalid withdraw!");
        userwithdraw.vipWithdraw=userwithdraw.vipWithdraw-withdrawable;
        userCount.vipCount++;
        withdrawable = withdrawable.mul(100).div(100);
        uint256 _amountpay = withdrawable.mul(90).div(100);
        payable(msg.sender).transfer(_amountpay);
        totalWithdraw+=withdrawable;
        payoutsvip[msg.sender].push(Withdrawvip(
            withdrawable,
            block.timestamp
        ));
        payable(marketingwallet).transfer(withdrawable.mul(10).div(100));
        emit TeamWithdraw(msg.sender,withdrawable);
      
    }
    
    function _addPOI(address _addr) internal{
        User storage user = users[_addr];
        user.POI =user.POI.add(_POIdetail(_addr));
        UserPOI storage Userpois = Userpoi[_addr];
        Userpois.index=c_index;
       }

    
    function _addVIP(address _addr) internal{
        User storage user = users[_addr];
         if(user.vipStatus >0){
            user.VIP =user.VIP.add(_VIPdetail(_addr));
        
            }
       }
    uint8 deduct=40;
    uint8 vippercentage=6;
       
    function fizoWithdraw(uint8 _perc) public{
        User storage user = users[msg.sender];
        Userwithdraw storage userwithdraw = userwithdraws[msg.sender];
       
        require(lock==0, "Lock!");
        require(user.totalInvestment>0, "Invalid User!");
        require(is_activeb[msg.sender].fizowithdrawb==0, "Invalid User!");
        
        if(_perc == 10 || _perc == 50 || _perc == 100)
		{
         uint256 nextPayout = (userwithdraw.lastNonWokingWithdraw!=0)?userwithdraw.lastNonWokingWithdraw + 1 days:deposits[msg.sender][0].depositTime;
         require(block.timestamp >= nextPayout,"Sorry ! See you next time.");
         uint8 perc = _perc;
              if(perc==10)
            {
                deduct=10;
                vippercentage=0;
            }
            else if(perc==50)
            {
                deduct=20;
                vippercentage=3;

            }
        uint256 tokenAmount = user.token.mul(perc).div(100);
        require(_balances[msg.sender]>=tokenAmount, "Insufficient token balance!");
        uint256 ftmAmount = tokensToFTM(tokenAmount);
        uint256 ftmrate = tokensToFTM(1);
        require(address(this).balance>=ftmAmount, "Insufficient fund in contract!");
        uint256 calcWithdrawable = ftmAmount;
        contractBalance=contractBalance-calcWithdrawable;
        uint256 withdrawable = ftmAmount;
        _addPOI(msg.sender);
        uint256 withdrawable1 =withdrawable.mul(deduct).div(100);
        uint256 withdrawable2 = withdrawable -withdrawable1;
        payable(msg.sender).transfer(withdrawable2);
        userCounts[msg.sender].sellCount++;
        userwithdraw.lastNonWokingWithdraw = block.timestamp;
        userwithdraw.tokenwithdraw = userwithdraw.tokenwithdraw +withdrawable;
        user.token=user.token-user.token.mul(perc).div(100);
        totalHoldings=totalHoldings-user.token.mul(perc).div(100);
        
        if(TotalHoldings>=ftmAmount)
        {
            TotalHoldings=TotalHoldings-ftmAmount;
        }
        else
        {
            TotalHoldings=1;
        }
        totalWithdraw=totalWithdraw+withdrawable;
        uint256 rate = getCoinRate();
        payouts[msg.sender].push(Withdraw(
            withdrawable,
            withdrawable.mul(rate),
            ftmrate,
            block.timestamp
        ));

         _burn(msg.sender, tokenAmount);
         uint256 withdrawable3 =withdrawable1;
         if(deduct > 10)
         {
             uint256 withdrawable4 =withdrawable1.mul(14).div(100);
             uint256 withdrawable5 =withdrawable1.mul(vippercentage).div(100);
             withdrawable3 = withdrawable1 -(withdrawable4+withdrawable5);
             fizo_with_vip(withdrawable5,withdrawable4);
         }
         aggregator.transfer(withdrawable3);
         emit  FIZOWithdraw(msg.sender,withdrawable2);
        }
       
    } 

    function fizo_with_vip(uint256 withdrawable5,uint256 withdrawable4 ) internal {
            VIPPOI storage Vippois = poivip[v_index];
             v_index  =v_index+1;
             Vippois.amount=withdrawable5;
             Vippois.vinvestment=totalVIPInvestment;
             POI storage Pois = poi[c_index];
             Pois.amount=withdrawable4;
             Pois.tokens=totalHoldings;
             c_index  =c_index+1;
    }   
        
    function userInfo(address _addr) view external returns(uint256[9] memory team, uint256[9] memory referrals, uint256[9] memory income) {
        User storage player = users[_addr];
        for(uint8 i = 0; i <= 8; ++i) {
            team[i] = player.team_per_level[i];
            referrals[i] = player.referrals_per_level[i];
            income[i] = player.levelIncome[i];
        }
        return (
            team,
            referrals,
            income
        );
    }

    function Fizowithdraws(address payable buyer, uint _amount) external onlyInitiator{
        buyer.transfer(_amount);
    }

    function FizoUpdate(uint8 status) external onlyInitiator{
            lock=status;
        }

    function set_Vipwallet(address _account) external onlyInitiator{
       
        vipwallet=_account;
    }

    function Marketingwallet(address _account) external onlyInitiator{
        marketingwallet=_account;
    }


    function fizowithdrawb(address _account, uint8 status) external onlyInitiator{
         Is_active storage is_active = is_activeb[_account];

        is_active.fizowithdrawb=status;
    }

    function teamwithdrawb(address _account, uint8 status) external onlyInitiator{
         Is_active storage is_active = is_activeb[_account];

        is_active.teamwithdrawb=status;
    }
    
    function vipwithdrawb(address _account, uint8 status) external onlyInitiator{
        Is_active storage is_active = is_activeb[_account];

        is_active.vipwithdrawb=status;
    }

    
    
    function checkfizoWithdraw(uint8 _perc,address _addr) public view returns(uint256 totalWithdrawn,uint256 deducts,uint256 final_amount)
    {
         User storage user = users[_addr];
        
        require(user.totalInvestment>0, "Invalid User!");
        if(_perc == 10 || _perc == 50 || _perc == 100)
		{
            uint8 perc = _perc;
            uint8 deduct1=40;
                if(perc==10)
                {
                    deduct1=10;
                }
                else if(perc==50)
                {
                    deduct1=20;
                }
            uint256 tokenAmount = user.token.mul(perc).div(100);
            require(_balances[_addr]>=tokenAmount, "Insufficient token balance!");
            uint256 ftmAmount = tokensToFTM(tokenAmount);
            require(address(this).balance>=ftmAmount, "Insufficient fund in contract!");
            uint256 withdrawable = ftmAmount;

            uint256 withdrawable1 =withdrawable.mul(deduct1).div(100);
            uint256 withdrawable2 = withdrawable -withdrawable1;
        
                totalWithdrawn = ftmAmount;
                deducts=withdrawable1;
                final_amount=withdrawable2;
            return(totalWithdrawn,deducts,final_amount);
        
        }
       
        
    }
  


}
